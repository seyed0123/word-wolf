"""Adapt the custom MADLAD GGUF header; copy quantized tensor bytes unchanged."""
import hashlib
import json
from pathlib import Path
import shutil
import struct
from sentencepiece import sentencepiece_model_pb2

FORMATS = {0: 'B', 1: 'b', 2: 'H', 3: 'h', 4: 'I', 5: 'i', 6: 'f', 7: '?', 10: 'Q', 11: 'q', 12: 'd'}


def number(stream, fmt):
    return struct.unpack('<' + fmt, stream.read(struct.calcsize('<' + fmt)))[0]


def string(stream):
    return stream.read(number(stream, 'Q')).decode('utf-8')


def value(stream, kind):
    if kind == 8:
        return string(stream)
    if kind == 9:
        subtype, count = number(stream, 'I'), number(stream, 'Q')
        return subtype, [value(stream, subtype) for _ in range(count)]
    return number(stream, FORMATS[kind])


def write_string(stream, text):
    raw = text.encode('utf-8')
    stream.write(struct.pack('<Q', len(raw)))
    stream.write(raw)


def write_value(stream, kind, item):
    if kind == 8:
        write_string(stream, item)
    elif kind == 9:
        subtype, values = item
        stream.write(struct.pack('<IQ', subtype, len(values)))
        for entry in values:
            write_value(stream, subtype, entry)
    else:
        stream.write(struct.pack('<' + FORMATS[kind], item))


def tensor_name(name):
    name = {'shared.embed.weight': 'token_embd.weight', 'shared.weight': 'token_embd.weight', 'token_embd.weight': 'token_embd.weight',
            'lm_head.weight': 'output.weight',
            'enc.final_rms.weight': 'enc.output_norm.weight',
            'dec.final_rms.weight': 'dec.output_norm.weight',
            'enc.rel_bias.weight': 'enc.blk.0.attn_rel_b.weight',
            'dec.rel_bias.weight': 'dec.blk.0.attn_rel_b.weight'}.get(name, name)
    return name.replace('.attn_rms.', '.attn_norm.').replace('.ffn_rms.', '.ffn_norm.') \
        .replace('.cross_rms.', '.cross_attn_norm.').replace('.cross_q.', '.cross_attn_q.') \
        .replace('.cross_k.', '.cross_attn_k.').replace('.cross_v.', '.cross_attn_v.') \
        .replace('.cross_o.', '.cross_attn_o.')


def prepare(source, output, tokenizer):
    with source.open('rb') as stream:
        if stream.read(4) != b'GGUF' or number(stream, 'I') != 3:
            raise ValueError('Expected a GGUF v3 model')
        count, entries = number(stream, 'Q'), number(stream, 'Q')
        metadata = {}
        for _ in range(entries):
            key, kind = string(stream), number(stream, 'I')
            metadata[key] = kind, value(stream, kind)
        if metadata.get('general.architecture') != (8, 't5'):
            raise ValueError('The suggester requires a MADLAD T5 model')
        if 't5.context_length' in metadata:
            shutil.copyfile(source, output)
            print('Copied an already standard T5 GGUF', flush=True)
            return
        expected = {'t5.d_model': 1024, 't5.d_kv': 128, 't5.d_ff': 8192, 't5.n_heads': 16,
                    't5.encoder.n_layers': 32, 't5.decoder.n_layers': 32, 't5.vocab_size': 256000}
        for key, expected_value in expected.items():
            if metadata.get(key, (None, None))[1] != expected_value:
                raise ValueError(f'Unsupported MADLAD layout: {key}')
        tensors = []
        for _ in range(count):
            name = string(stream)
            dimensions = [number(stream, 'Q') for _ in range(number(stream, 'I'))]
            kind, offset = number(stream, 'I'), number(stream, 'Q')
            tensors.append((tensor_name(name), dimensions, kind, offset))
        names = [row[0] for row in tensors]
        if len(set(names)) != count or 'token_embd.weight' not in names:
            raise ValueError('Unsupported or duplicated tensor names: ' + ', '.join(n for n in names if '.blk.' not in n))
        alignment = metadata.get('general.alignment', (4, 32))[1]
        original_data = (stream.tell() + alignment - 1) // alignment * alignment
        model = sentencepiece_model_pb2.ModelProto()
        model.ParseFromString(tokenizer.read_bytes())
        if [piece.piece for piece in model.pieces] != metadata['tokenizer.ggml.tokens'][1][1]:
            raise ValueError('Official tokenizer IDs do not match the local model')
        additions = {'t5.context_length': 512, 't5.embedding_length': 1024,
                     't5.feed_forward_length': 8192, 't5.block_count': 32, 't5.decoder_block_count': 32,
                     't5.attention.head_count': 16, 't5.attention.key_length': 128,
                     't5.attention.value_length': 128, 't5.attention.relative_buckets_count': 32,
                     't5.decoder_start_token_id': 0, 'tokenizer.ggml.bos_token_id': 1,
                     'tokenizer.ggml.eos_token_id': 2, 'tokenizer.ggml.unknown_token_id': 0,
                     'tokenizer.ggml.padding_token_id': 1}
        metadata.update({key: (4, entry) for key, entry in additions.items()})
        metadata.update({'t5.attention.layer_norm_rms_epsilon': (6, 1e-6),
                         'tokenizer.ggml.add_bos_token': (7, False),
                         'tokenizer.ggml.add_space_prefix': (7, model.normalizer_spec.add_dummy_prefix),
                         'tokenizer.ggml.remove_extra_whitespaces': (7, model.normalizer_spec.remove_extra_whitespaces),
                         'tokenizer.ggml.add_eos_token': (7, True),
                         'tokenizer.ggml.scores': (9, (6, [p.score for p in model.pieces])),
                         'tokenizer.ggml.token_type': (9, (5, [1 if p.type == 4 else p.type for p in model.pieces])),
                         'tokenizer.ggml.precompiled_charsmap': (9, (0, model.normalizer_spec.precompiled_charsmap))})
        if not model.normalizer_spec.precompiled_charsmap:
            metadata.pop('tokenizer.ggml.precompiled_charsmap', None)
        with output.open('wb') as target:
            target.write(b'GGUF' + struct.pack('<IQQ', 3, count, len(metadata)))
            for key, (kind, entry) in metadata.items():
                write_string(target, key)
                target.write(struct.pack('<I', kind))
                write_value(target, kind, entry)
            for name, dimensions, kind, offset in tensors:
                write_string(target, name)
                target.write(struct.pack('<I', len(dimensions)))
                for dimension in dimensions:
                    target.write(struct.pack('<Q', dimension))
                target.write(struct.pack('<IQ', kind, offset))
            target.write(b'\0' * (-target.tell() % alignment))
            new_data = target.tell()
            stream.seek(original_data)
            original_hash = hashlib.sha256()
            while block := stream.read(8 * 1024 * 1024):
                original_hash.update(block)
                target.write(block)
        with output.open('rb') as check:
            check.seek(new_data)
            if hashlib.file_digest(check, 'sha256').digest() != original_hash.digest():
                raise ValueError('Tensor bytes changed during conversion')
        print(f'Adapted {count} tensors; unchanged tensor SHA-256: {original_hash.hexdigest()}', flush=True)


if __name__ == '__main__':
    source, output = Path('/input/model.gguf'), Path('/output/model.gguf')
    tokenizer = Path('/app/spiece.model')
    with source.open('rb') as stream:
        signature = hashlib.file_digest(stream, 'sha256').hexdigest()
    signature += hashlib.sha256(Path(__file__).read_bytes() + tokenizer.read_bytes()).hexdigest()
    stamp = output.with_suffix('.json')
    if output.exists() and stamp.exists() and json.loads(stamp.read_text()) == {'signature': signature, 'size': output.stat().st_size}:
        print('Compatible MADLAD model already prepared', flush=True)
    else:
        temporary = output.with_suffix('.tmp')
        prepare(source, temporary, tokenizer)
        temporary.replace(output)
        stamp.write_text(json.dumps({'signature': signature, 'size': output.stat().st_size}))
