#include <windows.h> 
#include <tchar.h>
#include <stdio.h> 
#include <strsafe.h>

#define BUFSIZE 4096 
#define VARNAME TEXT("CYGWIN") 
#define VARVALUE TEXT("nodosfilewarning") 

/* child process's STDIN is the user input or data that you enter into the child process - READ */
HANDLE g_hChildStd_IN_Rd = NULL;
/* child process's STDIN is the user input or data that you enter into the child process - WRITE */
HANDLE g_hChildStd_IN_Wr = NULL;
/* child process's STDOUT is the program output or data that child process returns - READ */
HANDLE g_hChildStd_OUT_Rd = NULL;
/* child process's STDOUT is the program output or data that child process returns - WRITE */
HANDLE g_hChildStd_OUT_Wr = NULL;

void CreateChildProcess(void);
void WriteToPipe(CHAR chBuf[]);
void ReadFromPipe(CHAR chBuf[]);
void ErrorExit(PTSTR);

int _tmain(int argc, TCHAR *argv[])
{
    SECURITY_ATTRIBUTES saAttr;

    printf("\n->Start of parent execution.\n");

    // Set the bInheritHandle flag so pipe handles are inherited. 

    saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
    saAttr.bInheritHandle = TRUE;
    saAttr.lpSecurityDescriptor = NULL;

    //child process's STDOUT is the program output or data that child process returns
    // Create a pipe for the child process's STDOUT. 
    if (!CreatePipe(&g_hChildStd_OUT_Rd, &g_hChildStd_OUT_Wr, &saAttr, 0))
        ErrorExit(TEXT("StdoutRd CreatePipe"));

    // Ensure the read handle to the pipe for STDOUT is not inherited.
    if (!SetHandleInformation(g_hChildStd_OUT_Rd, HANDLE_FLAG_INHERIT, 0))
        ErrorExit(TEXT("Stdout SetHandleInformation"));

    //child process's STDIN is the user input or data that you enter into the child process
    // Create a pipe for the child process's STDIN. 
    if (!CreatePipe(&g_hChildStd_IN_Rd, &g_hChildStd_IN_Wr, &saAttr, 0))
        ErrorExit(TEXT("Stdin CreatePipe"));

    // Ensure the write handle to the pipe for STDIN is not inherited. 
    if (!SetHandleInformation(g_hChildStd_IN_Wr, HANDLE_FLAG_INHERIT, 0))
        ErrorExit(TEXT("Stdin SetHandleInformation"));
    // Create the child process. 

    CreateChildProcess();

    /* variables */
    char FAR *lpsz;
    int cch;

    CHAR chBuf[BUFSIZE];
    DWORD dwRead = strlen(chBuf);
    HANDLE hStdin;
    BOOL bSuccess;

    hStdin = GetStdHandle(STD_INPUT_HANDLE);
    if (hStdin == INVALID_HANDLE_VALUE)
        ExitProcess(1);

    for (;;)
    {
        // Read from standard input and stop on error or no data.
        bSuccess = ReadFile(hStdin, chBuf, BUFSIZE, &dwRead, NULL);

        if (!bSuccess || dwRead == 0)
            break;

        lpsz = &chBuf[0];

        // Write to the pipe that is the standard input for a child process. 
        // Data is written to the pipe's buffers, so it is not necessary to wait
        // until the child process is running before writing data.
        WriteToPipe(lpsz);
        printf("\n->Contents of %s written to child STDIN pipe.\n", argv[1]);
		CHAR FAR lrgstr[BUFSIZE];
        ReadFromPipe(lrgstr);
		// Read from pipe that is the standard output for child process. 
		lrgstr[strcspn(lrgstr, "\n")] = '\0';
        printf("\n->Contents of child process STDOUT:\n%s\n", lrgstr);
        printf("\n->End of parent execution.\n");
        // The remaining open handles are cleaned up when this process terminates. 
        // To avoid resource leaks in a larger application, close handles explicitly.
    }
    return 0;
}

void CreateChildProcess()
// Create a child process that uses the previously created pipes for STDIN and STDOUT.
{
	if (!SetEnvironmentVariable(VARNAME, VARVALUE))
	{
		ErrorExit(TEXT("SetEnvironmentVariable failed"));
	}
    TCHAR szCmdline[] = TEXT("cmd.exe /c \"C:\\Users\\rcastro\\Documents\\RCastroq\\CloudStorage\\DropBox00001\\Dropbox\\RunaSimi\\MicrosoftOffice\\win32\\lookup.exe C:\\Users\\rcastro\\Documents\\RCastroq\\CloudStorage\\DropBox00001\\Dropbox\\RunaSimi\\MicrosoftOffice\\win32\\asheninka.bin -q -d -flags cnKv29TT\"");
    PROCESS_INFORMATION piProcInfo;
    STARTUPINFO siStartInfo;
    BOOL bSuccess = FALSE;

    // Set up members of the PROCESS_INFORMATION structure. 

    ZeroMemory(&piProcInfo, sizeof(PROCESS_INFORMATION));

    // Set up members of the STARTUPINFO structure. 
    // This structure specifies the STDIN and STDOUT handles for redirection.

    ZeroMemory(&siStartInfo, sizeof(STARTUPINFO));
    siStartInfo.cb = sizeof(STARTUPINFO);
    siStartInfo.hStdError = g_hChildStd_OUT_Wr;
    siStartInfo.hStdOutput = g_hChildStd_OUT_Wr;
    siStartInfo.hStdInput = g_hChildStd_IN_Rd;
    siStartInfo.dwFlags |= STARTF_USESTDHANDLES;

    // Create the child process. 

    bSuccess = CreateProcess(NULL,
        szCmdline,     // command line 
        NULL,          // process security attributes 
        NULL,          // primary thread security attributes 
        TRUE,          // handles are inherited 
        0,             // creation flags 
        NULL,          // use parent's environment 
        NULL,          // use parent's current directory 
        &siStartInfo,  // STARTUPINFO pointer 
        &piProcInfo);  // receives PROCESS_INFORMATION 

    // If an error occurs, exit the application. 
    if (!bSuccess)
        ErrorExit(TEXT("CreateProcess"));
    else
    {
        // Close handles to the child process and its primary thread.
        // Some applications might keep these handles to monitor the status
        // of the child process, for example. 
        CloseHandle(piProcInfo.hProcess);
        CloseHandle(piProcInfo.hThread);
    }
}

void WriteToPipe(CHAR chBuf[])
// Read from a file and write its contents to the pipe for the child's STDIN.
// Stop when there is no more data. 
{
    DWORD dwRead, dwWritten;
    //CHAR chBuf2[] = "mapi\n";
	//strcat(chBuf, "\n");
	//chBuf[strcspn(chBuf, "\n")] = '\0';
	dwRead = strlen(chBuf);
	chBuf[dwRead] = '\n';
    BOOL bSuccess = FALSE;
    bSuccess = WriteFile(g_hChildStd_IN_Wr, chBuf, dwRead, &dwWritten, NULL);
    if (!bSuccess) ErrorExit(TEXT("StdInWr Cannot write into child process."));
    /*
    // Close the pipe handle so the child process stops reading. 
    if (!CloseHandle(g_hChildStd_IN_Wr))
        ErrorExit(TEXT("StdInWr CloseHandle"));
    */
}

void ReadFromPipe(CHAR chBuf[])
// Read output from the child process's pipe for STDOUT
// and write to the parent process's pipe for STDOUT. 
// Stop when there is no more data. 
{
    DWORD dwRead, dwWritten;
    BOOL bSuccess = FALSE;
    //HANDLE hParentStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
    //WORD wResult = 0;
    bSuccess = ReadFile(g_hChildStd_OUT_Rd, chBuf, BUFSIZE, &dwRead, NULL);
    if (!bSuccess || dwRead == 0) ErrorExit(TEXT("StdOutRd Cannot read child process's output."));
    if (chBuf[0] == '+' && chBuf[1] == '?') { printf("It's misspelled."); }
    else { printf("It's spelled correctly."); }
    // bSuccess = WriteFile(hParentStdOut, chBuf, dwRead, &dwWritten, NULL);
    // if (!bSuccess) ErrorExit(TEXT("StdOutWr Cannot write into parent process's output."));
}

void ErrorExit(PTSTR lpszFunction)
// Format a readable error message, display a message box, 
// and exit from the application.
{
    LPVOID lpMsgBuf;
    LPVOID lpDisplayBuf;
    DWORD dw = GetLastError();

    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER |
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        dw,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR)&lpMsgBuf,
        0, NULL);

    lpDisplayBuf = (LPVOID)LocalAlloc(LMEM_ZEROINIT,
        (lstrlen((LPCTSTR)lpMsgBuf) + lstrlen((LPCTSTR)lpszFunction) + 40)*sizeof(TCHAR));
    StringCchPrintf((LPTSTR)lpDisplayBuf,
        LocalSize(lpDisplayBuf) / sizeof(TCHAR),
        TEXT("%s failed with error %d: %s"),
        lpszFunction, dw, lpMsgBuf);
    MessageBox(NULL, (LPCTSTR)lpDisplayBuf, TEXT("Error"), MB_OK);

    LocalFree(lpMsgBuf);
    LocalFree(lpDisplayBuf);
    ExitProcess(1);
}
