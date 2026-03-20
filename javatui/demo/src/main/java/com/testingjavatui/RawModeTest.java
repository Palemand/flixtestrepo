package com.testingjavatui;

import java.io.IOException;

public class RawModeTest {
    public static void main(String[] args) throws Exception {
        // 1. Save the current terminal settings so we can restore them later
        String originalConfig = stty("-g");

        try {
            // 2. Switch to raw mode
            // -echo: don't print what the user types
            // -icanon: read character by character (don't wait for Enter)
            stty("-echo -icanon min 1");

            System.out.println("Raw mode active. Press 'q' to quit.");
            
            while (true) {
                int i = System.in.read();
                if (i == -1 || i == 'q') break;
                System.out.print("\rYou pressed: " + (char)i + " (ASCII: " + i + ")    ");
            }
        } finally {
            // 3. CRITICAL: Always restore the terminal or the user's shell will be broken
            stty(originalConfig);
            System.out.println("\nTerminal restored.");
        }
    }

    private static String stty(String args) throws IOException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder("sh", "-c", "stty " + args + " < /dev/tty");
        Process p = pb.start();
        p.waitFor();
        return new String(p.getInputStream().readAllBytes()).trim();
    }
}