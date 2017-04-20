
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.net.URL;
import java.nio.charset.Charset;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Formatter;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import java.io.*;
import java.net.*;

public class Client {

    protected Process lookup = null;
    protected OutputStream fl_wr = null;
    protected InputStream fl_rd = null;

    protected File lookup_bin = null;
    protected File fmed_bin = null;
    protected String[] command = null;
    protected File foma_file = null;
    protected Pattern rx = Pattern.compile("(\\S+)");
    protected Matcher rx_m = this.rx.matcher("");
    protected Pattern rx_pb = Pattern.compile("^\\p{Punct}+(\\S+?)$");
    protected Matcher rx_pb_m = this.rx_pb.matcher("");
    protected Pattern rx_pe = Pattern.compile("^(\\S+?)\\p{Punct}+$");
    protected Matcher rx_pe_m = this.rx_pe.matcher("");
    protected Pattern rx_pbe = Pattern.compile("^\\p{Punct}+(\\S+?)\\p{Punct}+$");
    protected Matcher rx_pbe_m = this.rx_pbe.matcher("");
    protected int position = 0;
    protected boolean debug = false;

    public static void main(String[] args)
            throws Exception {
        System.out.println("Initializing client");

        Client temp = new Client();
        temp.debug = true;
        String clientSentence;
        String capitalizedSentence;
        ServerSocket welcomeSocket = new ServerSocket(6789);
        System.err.println("Iniciando servidor.\n");
        while(true)
        {
          Socket connectionSocket = welcomeSocket.accept();
          BufferedReader inFromClient =
          new BufferedReader(new InputStreamReader(connectionSocket.getInputStream()));
          DataOutputStream outToClient = new DataOutputStream(connectionSocket.getOutputStream());
          clientSentence = inFromClient.readLine();
          //System.err.println("jkjk.\n");
          System.err.println("Received: " + clientSentence);
          temp.analyze(clientSentence+"\n");
          capitalizedSentence = clientSentence.toUpperCase() + '\n';
          outToClient.writeBytes(capitalizedSentence);
        }
    }

    public Client() {
        System.err.println("os.name\t" + System.getProperty("os.name"));
        System.err.println("os.arch\t" + System.getProperty("os.arch"));
        try {
            URL url = null;
            URL fm_url = null;
            this.command = new String[]{"/bin/bash", "-c", ""};
            url = getClass().getResource("bin/lookup");
            this.lookup_bin = new File(url.toURI());
            
            if ((!this.lookup_bin.canExecute()) && (!this.lookup_bin.setExecutable(true))) {
                throw new Exception("Foma's lookup is not executable and could not be made executable!\nTried to execute " + this.lookup_bin.getCanonicalPath());
            }

            this.foma_file = new File(getClass().getResource("lookup.script").toURI());
            if (!this.foma_file.canRead()) {
                throw new Exception("lookup.script is not readable!");
            }

            ProcessBuilder pb = new ProcessBuilder(new String[]{lookup_bin.getAbsolutePath(), "-f", foma_file.getAbsolutePath()});
            Map<String, String> env = pb.environment();
            env.put("CYGWIN", "nodosfilewarning");

            this.lookup = pb.start();

            this.fl_wr = this.lookup.getOutputStream();
            this.fl_rd = this.lookup.getInputStream();
        } catch (Exception ex) {
            System.err.println( ex.getMessage() );
        }
    }

    public synchronized boolean analyze(String word) {
        if ((this.lookup == null) || (this.fl_wr == null) || (this.fl_rd == null)) {
            return false;
        }
        if (getAnalysis(word)) {
            return true;
        }
        //String lword = word.toLowerCase();
        //if ((!word.equals(lword)) && (isValidWord(lword))) {
        //    return true;
        //}
        //this.rx_pe_m.reset(word);
        //if (this.rx_pe_m.matches()) {
        //    if (isValidWord(this.rx_pe_m.group(1))) {
        //        return true;
        //    }
        //    if (isValidWord(this.rx_pe_m.group(1).toLowerCase())) {
        //        return true;
        //    }
        //}
        //this.rx_pb_m.reset(word);
        //if (this.rx_pb_m.matches()) {
        //    if (isValidWord(this.rx_pb_m.group(1))) {
        //        return true;
        //    }
        //    if (isValidWord(this.rx_pb_m.group(1).toLowerCase())) {
        //        return true;
        //    }
        //}
        //this.rx_pbe_m.reset(word);
        //if (this.rx_pbe_m.matches()) {
        //    if (isValidWord(this.rx_pbe_m.group(1))) {
        //        return true;
        //    }
        //    if (isValidWord(this.rx_pbe_m.group(1).toLowerCase())) {
        //        return true;
        //    }
        //}
        return false;
    }

    public synchronized String[] getAlternatives(String word) {
        String[] rv = new String[0];
        try {
            if ((this.fmed_bin == null) || (this.lookup_bin == null) || (this.foma_file == null)) {
                return rv;
            }
            rv = alternatives(word);
            if (isAllUpperCase(word)) {
                for (int i = 0; i < rv.length; i++) {
                    rv[i] = rv[i].toUpperCase();
                }
            }
            if (startWithCapitalLetter(word)) {
                for (int i = 0; i < rv.length; i++) {
                    rv[i] = rv[i].substring(0, 1).toUpperCase() + rv[i].substring(1, rv[i].length()).toLowerCase();
                }
            }
        } catch (Exception ex) {
            return rv;
        }
        return rv;
    }

    public String[] alternatives(String word) {
        String[] rv = new String[0];
        word = word.trim().toLowerCase();
        try {
            String ret = "";
            ProcessBuilder pb = new ProcessBuilder(new String[]{this.fmed_bin.getAbsolutePath(), "-l15", this.foma_file.getAbsolutePath()});
            pb.redirectErrorStream(true);
            Process process = null;
            try {
                process = pb.start();
            } catch (IOException e) {
                System.out.println("Couldn't start the process.");
                e.printStackTrace();
            }
            System.out.println("reading");
            try {
                if (process != null) {
                    BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(process.getOutputStream(), "UTF-8"));
                    bw.write(word);
                    bw.newLine();
                    bw.close();
                }
            } catch (IOException e) {
                System.out.println("Either couldn't read from the template file or couldn't write to the OutputStream.");
                e.printStackTrace();
            }
            BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream(), "UTF-8"));
            String currLine = null;
            try {
                while ((currLine = br.readLine()) != null) {
                    ret = currLine;
                    System.out.println(currLine);
                }
            } catch (IOException e) {
                System.out.println("Couldn't read the output.");
                e.printStackTrace();
            }
            String delimiter = ",";
            if (ret.contains(delimiter)) {
                rv = ret.split(delimiter);
            } else {
                rv = new String[1];
                rv[0] = ret;
            }
        } catch (Exception ex) {
            return rv;
        }
        return rv;
    }

//    protected SingleProofreadingError processWord(String word, int start) {
//        if (this.debug) {
//            System.err.println(word + "\t" + start);
//        }
//        if (isValid(word)) {
//            return null;
//        }
//        SingleProofreadingError err = new SingleProofreadingError();
//        err.nErrorStart = start;
//        err.nErrorLength = word.length();
//        err.nErrorType = 1;
//        return err;
//    }

    public boolean getAnalysis(String word) {
        System.err.println("PRUEBA01.\n");
        word = word + "\n";
        byte[] res = new byte[4];
        try {
            this.fl_wr.write(word.getBytes(Charset.forName("UTF-8")));
            this.fl_wr.flush();
            if (this.fl_rd.read(res, 0, 4) != 4) {
                throw new Exception("Failed to read first 4 bytes from lookup!");
            }
            int avail = this.fl_rd.available();
            byte[] res2 = new byte[4 + avail];
            System.arraycopy(res, 0, res2, 0, 4);
            res = res2;
            if (this.fl_rd.read(res2, 4, avail) != avail) {
                throw new Exception("Failed to read first 4 bytes from lookup!");
            } else {
                String s = new String(res);
                System.out.println("RES: " + s + "\n");
            }
        } catch (Exception ex) {
            return false;
        }
        return (res[0] != 43) || (res[1] != 63) || (res[2] != 10);
    }

    public static String makeHash(byte[] convertme) {
        MessageDigest md = null;
        try {
            md = MessageDigest.getInstance("SHA-1");
        } catch (Throwable t) {
        }
        try {
            md = MessageDigest.getInstance("MD5");
        } catch (Throwable t) {
        }
        return byteArray2Hex(md.digest(convertme));
    }

    private static String byteArray2Hex(byte[] hash) {
        Formatter formatter = new Formatter();
        for (byte b : hash) {
            formatter.format("%02x", new Object[]{Byte.valueOf(b)});
        }
        return formatter.toString();
    }

    public boolean isAllUpperCase(String word) {
        String pattern = "[A-Z]*";
        if (word.matches(pattern)) {
            return true;
        }
        if (word.length() <= 0) {
            return false;
        }
        for (int i = 0; i < word.length(); i++) {
            String w = word.substring(i, i + 1);
            if (!(isCapitalLetter(w))) {
                return false;
            }
        }
        return true;
    }

    public boolean isCapitalLetter(String w) {
        String[] capitalLetter = new String[]{"�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�",
            "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R",
            "S", "T", "U", "V", "W", "X", "Y", "Z"};
        for (String str : capitalLetter) {
            if (str.equals(w)) {
                return true;
            }
        }
        return false;
    }

    public boolean startWithCapitalLetter(String word) {
        String pattern = "[A-Z][a-z]*";
        if (word.matches(pattern)) {
            return true;
        }
        if (word.length() <= 0) {
            return false;
        }
        for (int i = 0; i < word.length(); i++) {
            String w = word.substring(i, i + 1);
            if (i == 0) {
                if (!isCapitalLetter(w)) {
                    return false;
                }
            } else {
                if (isCapitalLetter(w)) {
                    return false;
                }
            }
        }
        return true;
    }
}
