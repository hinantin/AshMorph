BEGIN { format = "| \"[=%s][%s]\" : \{\%s}\n" 
 printf "%s\n", "# -----------------------------------------------------------" 
 printf "%s\n", "# The vocabulary here by presented was extracted" 
 printf "%s\n", "# from the Freeling Project http://nlp.lsi.upc.edu/freeling/" 
 printf "%s\n\n", "# -----------------------------------------------------------" 
 printf "%s%s%s\n", "define NRootESFreelingin", order, " [" 
}
NR==1 {printf "  \"[=%s][%s]\" : \{\%s}\n", $1, $3, $1}
NR>1 { printf format, $1, $3, $1 }
END { printf "%s", "];" }
