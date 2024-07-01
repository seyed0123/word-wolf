package com.example.restapi;

import org.json.JSONObject;

import java.io.*;
import java.net.Socket;

public class Clinet {
    private static Socket socket;
    private static BufferedReader in;
    private static PrintWriter out;
    private static DataInputStream dataIn;
    private static ObjectInputStream objectIn;
    private static ObjectOutputStream objectOut;
    private static JSONObject json;
    public static void main(String[] args) {
        String IP = "127.0.0.1";
        short port = 1234;
        try {
            socket = new Socket(IP, port);
            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            out = new PrintWriter(socket.getOutputStream(), true);
            objectIn = new ObjectInputStream(socket.getInputStream());
            dataIn = new DataInputStream(socket.getInputStream());
            objectOut = new ObjectOutputStream(socket.getOutputStream());

            json = new JSONObject();
            json.put("operation", "login");
            json.put("username", "amir");
            json.put("password", "1234");
            json.put("deviceID", "id34516545");
            System.out.println(json);
            objectOut.writeObject(json.toString());
        }
        catch (IOException e) {
            e.printStackTrace();
            System.out.println("Server is busy.");
        }
    }
}
