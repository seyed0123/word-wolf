package com.example.restapi;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class ServerMain {
    static short port = 1234;
    public static void main(String[] args) {
        ServerSocket serverSocket = null;
        try {
            serverSocket = new ServerSocket(port);
            System.out.println("Server started...");
            DataBase.connect();
        } catch (IOException e) {
            e.printStackTrace();
        }

        while (true) {
            try {
                System.out.println("Waiting for a new client ...");
                Socket socket = serverSocket.accept();
                System.out.println("New client connected: " + socket.getRemoteSocketAddress());
                ClientHandler client = new ClientHandler(socket);
                client.start();
            } catch (IOException e) {
                e.printStackTrace();
                break;
            }
        }
    }
}