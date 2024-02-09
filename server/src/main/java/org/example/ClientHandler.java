package org.example;

import org.json.JSONObject;

import java.io.*;
import java.net.Socket;

public class ClientHandler extends Thread {
    private final Socket socket;
    private DataOutputStream dataOut;
    private ObjectOutputStream objectOut;
    private ObjectInputStream objectIn;
    private JSONObject json;
    private User currentUser;
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
        // get device id
        try {
            String str = (String) objectIn.readObject();
            json = new JSONObject(str);
        } catch (ClassNotFoundException | IOException e) {
            System.out.println("client: " + Thread.currentThread().getName() + " exited.(exception in run function)");
            throw new RuntimeException(e);
        }
        // check remember me
        if(DataBase.rememberMe(json.getString("deviceID"))) {
            this.currentUser = DataBase.getUser(json.getString("deviceID"));
            mainMenu();
        } else {
            // get user details
            try {
                String str = (String) objectIn.readObject();
                json = new JSONObject(str);
            } catch (ClassNotFoundException | IOException e) {
                System.out.println("client: " + Thread.currentThread().getName() + " exited.(exception 2 in run function)");
                throw new RuntimeException(e);
            }

            if(json.get("operation").equals("login")) {
                login();
            } else if (json.get("operation").equals("signup")){
                signup();
            }
        }
        System.out.println("client: " + Thread.currentThread().getName() + " exited.");
    }

    private void login() {
        boolean loginFail = false;
        json = new JSONObject();
        // check login details(password correctness, ...)
        if(DataBase.usernameExist(json.getString("username"))) {
            if(DataBase.checkPassword(json.getString("username"), json.getString("password"))) {
                json.put("error", "none");
                this.currentUser = new User(json);
                mainMenu();
            } else {
                json.put("error", "password");
                loginFail = true;
            }
        } else {
            json.put("error", "username");
            loginFail = true;
        }

        // send json to client
        try {
            objectOut.writeObject(json.toString());
        } catch (IOException e) {
            System.out.println("client: " + Thread.currentThread().getName() + ": failed to send json in login func.");
            throw new RuntimeException(e);
        }

        if(loginFail) run();
    }
    private void signup() {
        User signingUser = new User(json);
        json = new JSONObject();
        boolean signupFail = false;
        if(DataBase.usernameExist(signingUser.getUsername())){
            signupFail = true;
            json.put("error", "usernameExists");
        } else if (!signingUser.getEmail().matches("^(\\w*|\\.)+@([a-zA-Z]+|\\d+)+\\.[a-zA-Z]{3}$")) {
            signupFail = true;
            json.put("error", "email");
        } else if (signingUser.getUsername().matches("^[\\w._-]+$")) {
            signupFail = true;
            json.put("error", "usernameChar");
        } else {
            json.put("error", "none");
            this.currentUser = signingUser;
            mainMenu();
        }

        // send json to client
        try {
            objectOut.writeObject(json.toString());
        } catch (IOException e) {
            System.out.println("client: " + Thread.currentThread().getName() + ": failed to send json in signup func.");
            throw new RuntimeException(e);
        }

        if(signupFail) run();
    }
    private void mainMenu() {

    }
}
