package com.testingjavatui;

public class Main {
    public static void main(String[] args) {
        try {
            RawModeTest.main(args);
        } catch (Exception e) {
            System.out.println(e.getStackTrace());
        }
    }
}

