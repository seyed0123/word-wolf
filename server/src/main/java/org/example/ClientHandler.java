package org.example;

import org.json.JSONObject;

import java.io.*;
import java.net.Socket;

public class ClientHandler extends Thread {
    private final Socket socket;
    private DataOutputStream dataOut;
    private ObjectOutputStream objectOut;
    private ObjectInputStream objectIn;
    JSONObject json;
    private boolean exitFlag = false;
    private String username;
    public ClientHandler(Socket socket) throws IOException {
        this.socket = socket;
        dataOut = new DataOutputStream(socket.getOutputStream());
        objectOut = new ObjectOutputStream(socket.getOutputStream());
        objectIn = new ObjectInputStream(socket.getInputStream());
    }

    @Override
    public void run() {
        try {
            String str = (String) objectIn.readObject();
            json = new JSONObject(str);

        } catch (ClassNotFoundException | IOException e) {
            System.out.println("client: " + Thread.currentThread().getName() + " exited.(exception in run function)");
            throw new RuntimeException(e);
        }

        if (DataBase.rememberMe(json.getString("device ID"), json.getString("username"))) {
            mainMenu();
        } else if(json.get("operation").equals("login")) {
            login();
        } else if (json.get("operation").equals("signup")){
            signup();
        }
        System.out.println("client: " + Thread.currentThread().getName() + " exited.");
    }

    private void login() {

    }
    private void signup() {}
    private void mainMenu() {}
}
