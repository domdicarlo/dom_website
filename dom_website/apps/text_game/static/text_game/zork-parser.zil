			"Generic PARSER file for
			    The ZORK Trilogy
		       started on 7/28/83 by MARC"
		
		  "Hacked by Dominic DiCarlo 4/2020 Quarantine Days"
			"Adding plenty of spacing and comments"

;"WHICH and TRAP retrofixes installed"

"Parser global variable convention:  All parser globals will
  begin with 'P-'.  Local variables are not restricted in any
  way.
"
<SETG SIBREAKS ".,\"">

;"verb"
<GLOBAL PRSA <>>
;"indirect object"
<GLOBAL PRSI <>>
;"object"
<GLOBAL PRSO <>>

<GLOBAL P-TABLE 0>
<GLOBAL P-ONEOBJ 0>
<GLOBAL P-SYNTAX 0>

<GLOBAL P-CCTBL <TABLE 0 0 0 0>>
;"pointers used by CLAUSE-COPY (source/destination beginning/end pointers)"
<CONSTANT CC-SBPTR 0>
<CONSTANT CC-SEPTR 1>
<CONSTANT CC-DBPTR 2>
<CONSTANT CC-DEPTR 3>

<GLOBAL P-LEN 0>
<GLOBAL P-DIR 0>
<GLOBAL HERE 0>
<GLOBAL WINNER 0>

<GLOBAL P-LEXV
	<ITABLE 59 (LEXV) 0 #BYTE 0 #BYTE 0> ;<ITABLE BYTE 120>>
<GLOBAL AGAIN-LEXV
	<ITABLE 59 (LEXV) 0 #BYTE 0 #BYTE 0> ;<ITABLE BYTE 120>>
<GLOBAL RESERVE-LEXV
	<ITABLE 59 (LEXV) 0 #BYTE 0 #BYTE 0> ;<ITABLE BYTE 120>>
<GLOBAL RESERVE-PTR <>>

;"INBUF - Input buffer for READ"

<GLOBAL P-INBUF
	<ITABLE 120 (BYTE LENGTH) 0>
	;<ITABLE BYTE 60>>
<GLOBAL OOPS-INBUF
	<ITABLE 120 (BYTE LENGTH) 0>
	;<ITABLE BYTE 60>>
<GLOBAL OOPS-TABLE <TABLE <> <> <> <>>>
<CONSTANT O-PTR 0>	"word pointer to unknown token in P-LEXV"
<CONSTANT O-START 1>	"word pointer to sentence start in P-LEXV"
<CONSTANT O-LENGTH 2>	"byte length of unparsed tokens in P-LEXV"
<CONSTANT O-END 3>	"byte pointer to first free byte in OOPS-INBUF"

;"Parse-cont variable"

<GLOBAL P-CONT <>>
<GLOBAL P-IT-OBJECT <>>
;<GLOBAL LAST-PSEUDO-LOC <>>

;"Orphan flag"

<GLOBAL P-OFLAG <>>
<GLOBAL P-MERGED <>>
<GLOBAL P-ACLAUSE <>>
<GLOBAL P-ANAM <>>
<GLOBAL P-AADJ <>>
;"Parser variables and temporaries"

;"Byte offset to # of entries in LEXV"

<CONSTANT P-LEXWORDS 1> ;"Word offset to start of LEXV entries"
<CONSTANT P-LEXSTART 1> ;"Number of words per LEXV entry"
<CONSTANT P-LEXELEN 2>
<CONSTANT P-WORDLEN 4> ;"Offset to parts of speech byte"

<CONSTANT P-PSOFF 4> ;"Offset to first part of speech"
<CONSTANT P-P1OFF 5> ;"First part of speech bit mask in PSOFF byte"
<CONSTANT P-P1BITS 3>

<CONSTANT P-ITBLLEN 9>
<GLOBAL P-ITBL <TABLE 0 0 0 0 0 0 0 0 0 0>>
<GLOBAL P-OTBL <TABLE 0 0 0 0 0 0 0 0 0 0>>
<GLOBAL P-VTBL <TABLE 0 0 0 0>>
<GLOBAL P-OVTBL <TABLE 0 #BYTE 0 #BYTE 0>>

<GLOBAL P-NCN 0>

<CONSTANT P-VERB 0>
<CONSTANT P-VERBN 1>
<CONSTANT P-PREP1 2>
<CONSTANT P-PREP1N 3>
<CONSTANT P-PREP2 4>
<CONSTANT P-PREP2N 5>
<CONSTANT P-NC1 6>
<CONSTANT P-NC1L 7>
<CONSTANT P-NC2 8>
<CONSTANT P-NC2L 9>

<GLOBAL QUOTE-FLAG <>>
<GLOBAL P-END-ON-PREP <>>

" Grovel down the input finding the verb, prepositions, and noun clauses.
   If the input is <direction> or <walk> <direction>, fall out immediately
   setting PRSA to ,V?WALK and PRSO to <direction>.  Otherwise, perform
   all required orphaning, syntax checking, and noun clause lookup."
<ROUTINE PARSER ("AUX" (PTR ,P-LEXSTART) WRD (VAL 0) (VERB <>) (OF-FLAG <>)
		       OWINNER OMERGED LEN (DIR <>) (NW 0) (LW 0) (CNT -1))
  ;"some loop"

	; "Okay so this first loop "
	; "I have the feeling we simply take all the words in the
	   input, and load them in."
  ; "Think like some primitive strtok"
	; "It's just a feeling though cuz Im not sure"
	<REPEAT ()
	 ; "If CNT + 1 > P-ITBLLEN, simply return"
	 ; "Hmm, I think P-ITBLLEN is some sort of upper bound on phrase length"
	 ; "Notice CNT starts as -1, so this first cond sets CNT to 0"
		<COND (<G? <SET CNT <+ .CNT 1>> ,P-ITBLLEN> <RETURN>)
				   ;"T here means ELSE essentially"

		      (T
					;"If the P-OFLAG is NOT set:"
		       <COND (<NOT ,P-OFLAG>
					;"Set the .CNT field of P-OTBL to the .CNT field of P-ITBL"
					;" Both are tables "
			      <PUT ,P-OTBL .CNT <GET ,P-ITBL .CNT>>)>
					; "Unconditionally, so long as we didnt return, set the .CNT"
					; "field of P-ITBL to 0"
		       <PUT ,P-ITBL .CNT 0>)>>


  ;"Set a bunch of variables. SETG is setting a global variable"
	<SET OWINNER ,WINNER>
	<SET OMERGED ,P-MERGED>
	<SETG P-ADVERB <>>
	<SETG P-MERGED <>>
	<SETG P-END-ON-PREP <>>
	; "This is an interesting move and Im not sure what to make of it"
	; "P-MATCHLEN gets set to 0 at some point"
	<PUT ,P-PRSO ,P-MATCHLEN 0>
	<PUT ,P-PRSI ,P-MATCHLEN 0>
	<PUT ,P-BUTS ,P-MATCHLEN 0>

	; "No idea what this cond is doing"
	; "Aside from setting HERE and LIT, which make sense"
	; "QUOTE-FLAG is off AND  some cmp with WINNER and PLAYER...
	   but not one where they are exactly equal either.."
	; "Since we see that we set winner to player in the next line"
	<COND (<AND <NOT ,QUOTE-FLAG> <N==? ,WINNER ,PLAYER>>
	       <SETG WINNER ,PLAYER>
				 ; "set 'here' to the location of the player"
	       <SETG HERE <META-LOC ,PLAYER>>
	       ;<COND (<NOT <FSET? <LOC ,WINNER> ,VEHBIT>>
		      <SETG HERE <LOC ,WINNER>>)>
				; "check whether the area we are at is LIT (fire lol)"
	       <SETG LIT <LIT? ,HERE>>)>

	<COND 
				; "First if CASE --> I'm thinking this one is asking 
				   if RESERVE-PTR is not equal to NULL"
				(,RESERVE-PTR
	 		   ; "set pointer to the reserve pointer"
	       <SET PTR ,RESERVE-PTR>
				 ; "I'm thinking this one means just copy the whole table into 
				    reserve-lexv"
	       <STUFF ,RESERVE-LEXV ,P-LEXV>
				 ; "check if player == winner AND SUPER-BRIEF is NOT true"
				 ; "(cant find this variable within this file, ta fuck?"
	       <COND (<AND <NOT ,SUPER-BRIEF> <EQUAL? ,PLAYER ,WINNER>>
				 ; "this just means carriage return line feed. Does this mean we just print
				    something? or return this? very confusing"
		      <CRLF>)>
				 ;" set back the pointer to nothing I guess?"
	       <SETG RESERVE-PTR <>>
	       <SETG P-CONT <>>)
				 
				; "Second else if CASE --> I'm thinking this one is asking 
				  if P-CONT is not equal to NULL"
	      (,P-CONT
					; "set this PTR var to P-CONT"
	       <SET PTR ,P-CONT>
				 ; "check if player == winner AND SUPER-BRIEF is NOT true AND the verb wasnt 'say'"
				 ; "(cant find this variable within this file, ta fuck?"
	       <COND (<AND <NOT ,SUPER-BRIEF> 
							<EQUAL? ,PLAYER ,WINNER>
							<NOT <VERB? SAY>>>
		      <CRLF>)>
					; "set this P-CONT global var to NULL again"
	       <SETG P-CONT <>>)

				; "Else CASE --"
	      (T
				; "set player to winner"
	       <SETG WINNER ,PLAYER>
				; "set QUOTE-FLAG to NULL ?"
	       <SETG QUOTE-FLAG <>>
				; "Checks if the VEHBIT is set for the WINNER's location (the player's location)"
				; "VEHBIT is vehicle. This doesn't mean vehicles strictly, but
				   anything a player can enter (i.e. a chair or a bed)"
	       <COND (<NOT <FSET? <LOC ,WINNER> ,VEHBIT>>
				  ;"set here to the location of the winner/player"
		      <SETG HERE <LOC ,WINNER>>)>

				;"set the lit boolean to whether or not HERE is lit"
	       <SETG LIT <LIT? ,HERE>> 
				;"if it's not super brief, output CRLF I guess"
	       <COND (<NOT ,SUPER-BRIEF> <CRLF>)>
				 ; "hmmm interesting. so this is where we print text to the screen
				   in particular we print the prompt here, meaning we are done?"
	       <TELL ">">
				 ; "read what's in P-INBUF into P-LEXV I believe"
	       <READ ,P-INBUF ,P-LEXV>)> 
; "End of reserve PTR cond"

	;"okay we are not in any sort of cond now"
	;"set P-LEN glob var to the P-LEXWORDS field of P-LEXV"
	<SETG P-LEN <GETB ,P-LEXV ,P-LEXWORDS>>
	; "if the length of the input or something is 0, we dunno what they said"
	<COND (<ZERO? ,P-LEN> <TELL "I beg your pardon?" CR> <RFALSE>)>

 ; "Cond on handling OOPS versus other commands" 
	<COND 
				; "First if case --> is the first word OOPS?"
				(<EQUAL? <SET WRD <GET ,P-LEXV .PTR>> ,W?OOPS>

				; "if the PTR + P-LEXELEN is equal to a period or comma"
	       <COND (<EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>
			      ,W?PERIOD ,W?COMMA>
						;" then you set the pointer to be plus P-LEXELEN"
		      <SET PTR <+ .PTR ,P-LEXELEN>>
					; "and you subtract one from the P-LEN"
		      <SETG P-LEN <- ,P-LEN 1>>)>

	       <COND 
					; "if P-LEN is not greater than 1"
					; "I think this means that the input was ONLY OOPS"
				 (<NOT <G? ,P-LEN 1>>
		      <TELL "I can't help your clumsiness." CR>
		      <RFALSE>)

				 ; "Second else if. If the O-PTR in the OOPS-TABLE is not NULL (?)"
		     (<GET ,OOPS-TABLE ,O-PTR>

		      <COND 
						(<AND <G? ,P-LEN 2>
						<EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>
							,W?QUOTE>>
						<TELL
						"Sorry, you can't correct mistakes in quoted text." CR>
						<RFALSE>)

						(<G? ,P-LEN 2>
						<TELL
							"Warning: only the first word after OOPS is used." CR>)
					>

					;"the rest is not in the above cond"
					; "set AGAIN-LEXV[O-PTR in the OOPS table: the val]
						 to P-LEXV[PTR + P-LEXELEN] "
		      <PUT ,AGAIN-LEXV <GET ,OOPS-TABLE ,O-PTR>
						<GET ,P-LEXV <+ .PTR ,P-LEXELEN>>>

		      <SETG WINNER .OWINNER> ;"maybe fix oops vs. chars.? NOT MY COMMENT -- THEIRS"

					;"This is a defined routine in the file, with the following desc:"
					;"Put the words in the positions specified from P-INBUF to the end of
					OOPS-INBUF, leaving the appropriate pointers in AGAIN-LEXV"
					; "After adding the following arguments, "
		      <INBUF-ADD 
						; "set len = P-LEXV[(PTR * P-LEXELEN) + 6] "
						<GETB ,P-LEXV <+ <* .PTR ,P-LEXELEN> 6>> ;"len"
						; "set beg = P-LEXV[(PTR * P-LEXELEN) + 7]"
						<GETB ,P-LEXV <+ <* .PTR ,P-LEXELEN> 7>> ;"beg"
						; "set slot = (OOPS-TABLE[O-PTR] * P-LEXELEN) + 3"
						<+ <* <GET ,OOPS-TABLE ,O-PTR> ,P-LEXELEN> 3> ;"slot">

					; "Put contents of P-LEXV into AGAIN-LEXV"
		      <STUFF ,AGAIN-LEXV ,P-LEXV>

					; "Set P-LEN glob var to P-LEXV[P-LEXWORDS]"
		      <SETG P-LEN <GETB ,P-LEXV ,P-LEXWORDS>>

					; "Set PTR = OOPS-TABLE[O-START]"
		      <SET PTR <GET ,OOPS-TABLE ,O-START>>

					;"Put contents of OOPS-INBUF into P-INBUF"
		      <INBUF-STUFF ,OOPS-INBUF ,P-INBUF>)

				 ; "ELSE case."
		     (T
		      <PUT ,OOPS-TABLE ,O-END <>>
		      <TELL "There was no word to replace!" CR>
		      <RFALSE>)>)
				; "End of COND on P-LEN"

				; "Else case --> Non OOPS command"
	      (T
				; "This is asking if the first WRD is NOT equal to AGAIN or G"
				; "If it's NOT, then set P-NUMBER = 0"
	       <COND 
				 (<NOT <EQUAL? .WRD ,W?AGAIN ,W?G>>
		      <SETG P-NUMBER 0>)>

					; "Set O-END in the OOPS-TABLE to NULL (<>)"
	       <PUT ,OOPS-TABLE ,O-END <>>)>
			; "End of cond on handling OOPS versus other commands" 


	; "start of Cond on P-LEXV[PTR]"
	<COND 
			; "If P-LEXV[PTR] = 'AGAIN' or 'G'"
			(<EQUAL? <GET ,P-LEXV .PTR> ,W?AGAIN ,W?G>

				; "Sub conds"

				; "sub cond 1"
	       <COND 
				 ; "If OOPS-INBUF[1] == 0"
				  (<ZERO? <GETB ,OOPS-INBUF 1>>
		      <TELL "Beg pardon?" CR>
		      <RFALSE>)

				 ; "If P-OFLAG is set"
		     (,P-OFLAG
		      <TELL "It's difficult to repeat fragments." CR>
		      <RFALSE>)

				 ; "If P-WON is set"
		     (<NOT ,P-WON>
		      <TELL "That would just repeat a mistake." CR>
		      <RFALSE>)

				 ; "If P-LEN is greater than 1"
		     (<G? ,P-LEN 1>
				  ; "Then do this"
		      <COND 
							; "If this:"
							; "If the input ends in period, comma, or 'then'"
							(<OR <EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>
														,W?PERIOD 
														,W?COMMA 
														,W?THEN>
										; "Or if input ends in AND"
										 <EQUAL? <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>
														,W?AND>> 
							; "Then do this"
							; "set PTR = PTR + (2 * P-LEXELEN)"
			     		<SET PTR <+ .PTR <* 2 ,P-LEXELEN>>>
						  ; "set P-LEXV[P-LEXWORDS] = P-LEXV[P-LEXWORDS] - 2"
			 		    <PUTB ,P-LEXV ,P-LEXWORDS
				 			  <- <GETB ,P-LEXV ,P-LEXWORDS> 2>>)
				  ; "Else case for OR statement"
							(T
							<TELL "I couldn't understand that sentence." CR>
							<RFALSE>)>)
				; "Else case for if P-LEN > 1 (so P-LEN <= 1)"
		     (T
				 ; "Set PTR = PTR + P-LEXELEN"
		      <SET PTR <+ .PTR ,P-LEXELEN>>
				 ; "Set P-LEXV[P-LEXWORDS] = P-LEXV[P-LEXWORDS] - 1"
		      <PUTB ,P-LEXV ,P-LEXWORDS
								<- <GETB ,P-LEXV ,P-LEXWORDS> 1>>)
				>
				; "end of sub cond 1"

				; "start of sub cond 2"
	      <COND 
		    ; "If P-LEXV[P-LEXWORDS] == 0:"
		  	(<G? <GETB ,P-LEXV ,P-LEXWORDS> 0>
			  ; "Then set RESERVE-LEXV = P-LEXV (or a memcpy)"
		      <STUFF ,P-LEXV ,RESERVE-LEXV>
			  ; "Set RESERVE-PTR = .PTR"
		      <SETG RESERVE-PTR .PTR>)

			  ; "Else case (P-LEXV[P-LEXWORDS] !== 0)"
		     (T
			  ; "Set RESERVE-PTR = NULL"
		      <SETG RESERVE-PTR <>>)>
				; "end of sub cond 2"

	       ;<SETG P-LEN <GETB ,AGAIN-LEXV ,P-LEXWORDS>> ; "not my doing - Dom"

	       <SETG WINNER .OWINNER>
	       <SETG P-MERGED .OMERGED>
			; "Set P-INBUF to OOPS-INBUF (makes sense for AGAIN)"
	       <INBUF-STUFF ,OOPS-INBUF ,P-INBUF>
		   ; "set P-LEXV to AGAIN-LEXV"
	       <STUFF ,AGAIN-LEXV ,P-LEXV>
		   ; "Set CNT to -1"
	       <SET CNT -1>
		   ; "Set DIR to AGAIN-DIR"
	       <SET DIR ,AGAIN-DIR>

		   ; "New loop. We want CNT "
	       <REPEAT ()
		   ; ""
			<COND 
				; "Increment and check if CNT > P-ITBLLEN"
			   (<IGRTR? CNT ,P-ITBLLEN> <RETURN>)
			    ; "Else,"
				(T 
					; "set P-ITBL[CNT] = P-OTBL[CNT]"
					<PUT ,P-ITBL .CNT <GET ,P-OTBL .CNT>>)>>
		)
		; "End of if case for AGAIN or G case"

		; "All other cases. Looks like we are headed to the meat of the parser"
    (T
		   ; "set AGAIN-LEXV to hold the same mem as P-LEXV"
	       <STUFF ,P-LEXV ,AGAIN-LEXV>
		   ; "Set OOPS-INBUF to hold the same memory as P-INBUF"
	       <INBUF-STUFF ,P-INBUF ,OOPS-INBUF>
		   ; "set OOPS-TABLE[O-START] = PTR"
	       <PUT ,OOPS-TABLE ,O-START .PTR>
		   ; "set OOPS-TABLE[O-LENGTH] = (4 * P-LEN)"
	       <PUT ,OOPS-TABLE ,O-LENGTH <* 4 ,P-LEN>>
		   ; "Set LEN = 2 * ( PTR + (P-LEXELEN * P-LEXV[P-LEXWORDS])) "
	       <SET LEN
		    <* 2 <+ .PTR <* ,P-LEXELEN <GETB ,P-LEXV ,P-LEXWORDS>>>>>
		   ; "Set OOPS-TABLE[O-END] = (P-LEXV[LEN - 1] + P-LEXV[LEN - 2])"
		   ; "Hmmm, I think this might be looking at the number of words total."
	       <PUT ,OOPS-TABLE ,O-END 
		   		  <+ <GETB ,P-LEXV <- .LEN 1>>
					  <GETB ,P-LEXV <- .LEN 2>>>>
            ; "Set RESERVE-PTR = NULL"
	       <SETG RESERVE-PTR <>>
		   ; "Set LEN = P-LEN"
	       <SET LEN ,P-LEN>
		   ; "Set P-DIR = NULL"
	       <SETG P-DIR <>>
		   ; "Set P-NCN = 0"
	       <SETG P-NCN 0>
		   ; "Set P-GETFLAGS = 0"
	       <SETG P-GETFLAGS 0>

		; "New loop (Huge Loop it turns out)"
		; "BFL (Big Fucking Loop)"
		<REPEAT ()
		  
		; "Start of mega COND"
			<COND 
			  ; "Exit case. --If P-LEN < 0"
			  (<L? <SETG P-LEN <- ,P-LEN 1>> 0>
			  ; "set QUOTE-FLAG = NULL"
			  <SETG QUOTE-FLAG <>>
			  <RETURN>)

       ; "Case 1 (big case): The word is not NULL"
		    (<OR 
				; "If the next word is either in the lexicon or a number"
				; "If either P-LEXV[PTR] !== NULL"
			    <SET WRD <GET ,P-LEXV .PTR>>
				; "Or PTR is a number"
			   	<SET WRD <NUMBER? .PTR>>>
				
				; "then do ALL below"

				; "Sub cond 1"
				; "Check if P-LEN == 0"
				<COND 
					;"If P-LEN == 0"
					(<ZERO? ,P-LEN> 
					;"Set NW = 0"
					<SET NW 0>)
					; "Else case:"
					(T 
						<SET NW <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>>)
				>
				; "ENDOF Sub cond 1"

				; "StartOF Sub cond 2"
				; ""
				<COND 
			    ; "here we have a check if its speech"
					(<AND <EQUAL? .WRD ,W?TO>
				  			<EQUAL? .VERB ,ACT?TELL ;,ACT?ASK>>

				  ; "THEN do"
					<SET WRD ,W?QUOTE>)

					( 
					; "If WRD == THEN 
					  && P-LEN > 0 
						&& NO Verb yet
						&& Not a quote (QUOTE-FLAG == NULL)"
					<AND <EQUAL? .WRD ,W?THEN>
				 		 	 <G? ,P-LEN 0>
					     <NOT .VERB>
					     <NOT ,QUOTE-FLAG> ;"Last NOT added 7/3"> ; "not my comment"

				  ; "Then do all below:"

					; "enter this new cond"
					<COND 

  					(	 ; "If LW == 0 || LW == '.' (a period)"
						<EQUAL? .LW 0 ,W?PERIOD>
						; "then set WRD = 'THE'"
						<SET WRD ,W?THE>)

						(ELSE
						; "Set P-ITBL[P-VERB] = TELL"
						<PUT ,P-ITBL ,P-VERB ,ACT?TELL>
						; "Set P-ITBL[P-VERBN] = 0"
						<PUT ,P-ITBL ,P-VERBN 0>
						; "Set WRD = QUOTE (I think? or maybe quote marks? unclear)"
						<SET WRD ,W?QUOTE>)>
					)
				>
				; "ENDOF sub cond 2"

				; "STARTOF sub cond 3 "
		   <COND 
			   
			   ; "WORD == 'THEN' || '.' || 'QUOTE OR QUOTATION MARKS'"
			 (<EQUAL? .WRD ,W?THEN ,W?PERIOD ,W?QUOTE>

				; "Then do:"				
				<COND 
				; "If WRD is a QUOTE or quotation marks"	
				(<EQUAL? .WRD ,W?QUOTE>
				    ;
					<COND 
					; "If QUOTE-FLAG is set, set QUOTE-FLAG = NULL"
					(,QUOTE-FLAG <SETG QUOTE-FLAG <>>)
					; "Else, set QUOTE-FLAG = NULL ( or something? IDK!)"
					(T <SETG QUOTE-FLAG T>)>)
				>

				; "simple OR: "
				; "dont get why this OR is there... when is its result evaluated?"
				; "depending on how the language evals an OR
				   statement, the first statement being true might
					 prevent the next statement from running"
				<OR 
				 	; "is P-LEN == 0?"
					<ZERO? ,P-LEN>
					; "or, is PTR + P-LEXELEN null or not? Set P-CONT to that val"
					<SETG P-CONT <+ .PTR ,P-LEXELEN>>
				>
				; "set P-LEN bytes of P-LEXV = P-LEXWORDS"
				;' "or, P-LEXV[0:P-LEN] = P-LEXWORDS[0:P-LEN]"
				<PUTB ,P-LEXV ,P-LEXWORDS ,P-LEN>
				<RETURN>)

				; "Okay let's unpack this boy"
				; "First, here is the condition:"
			  (<AND 

				 	<SET VAL
					    ; "Checks if WRD is the correct part of speech. This checks"
						; "if word is a direction I believe."
						<WT? .WRD
							,PS?DIRECTION
							,P1?DIRECTION>>
						; "This whole thing sets VAL to the DIRECTION (if given)"
						; "So maybe this only works if the command is to GO somewhere?"

					; "Check is VERB == ACT?WALK"
					; "So above hypothesis seems correct"
				   <EQUAL? .VERB <> ,ACT?WALK>

					; "One of these"

					; "Len == 1"
				   <OR <EQUAL? .LEN 1>
						; "LEN == 2"
				       <AND <EQUAL? .LEN 2>
					    ; "And the verb is ACT?WALK"
							<EQUAL? .VERB ,ACT?WALK>>

						; "NW == THEN || . || "QUOTE""
				       <AND <EQUAL? .NW
					            ,W?THEN
					            ,W?PERIOD
					            ,W?QUOTE>
				            ;"and LEN < 2"
							<NOT <L? .LEN 2>>>

						; "QUOTE-FLAG is on"
				       <AND ,QUOTE-FLAG
					       ; "LEN == 2"
							<EQUAL? .LEN 2>
							; "NW == "QUOTE""
							<EQUAL? .NW ,W?QUOTE>>

				       <AND 
							; "LEN > 2"
					   		<G? .LEN 2>
							 ; "NW == COMMA || NW == AND"
							<EQUAL? .NW ,W?COMMA ,W?AND>>
					>
				>

				; "Then: "
				 ; "set DIR = VAL"
			      <SET DIR .VAL>

			      <COND 
				     ; "IF NW == , || NW == AND"
				    (<EQUAL? .NW ,W?COMMA ,W?AND>
					; "Set P-LEXV[PTR + P-LEXELEN] = THEN"
				     <PUT ,P-LEXV
					  <+ .PTR ,P-LEXELEN>
					  ,W?THEN>)>

			      <COND 
				    ; "If ! (LEN > 2)"
				  	(<NOT <G? .LEN 2>>

					  ; "Set QUOTE-FLAG = NULL"
				     <SETG QUOTE-FLAG <>>
				     <RETURN>)>
				  )
				; "End of GO subcase"

			  ; "Verb subcase"
			  (
				  ; "If this:"
				  <AND 
					; "Set VAL = a verb if WRD is a verb"
					<SET VAL <WT? .WRD ,PS?VERB ,P1?VERB>>
					; "VERB is NOT (maybe, VERB is not filled yet?)"
					<NOT .VERB>>
				
				  ; "Then do this: "
				  ; "set VERB = VAL"
			      <SET VERB .VAL>
				  ; "set P-ITBL[P-VERB] = VAL"
			      <PUT ,P-ITBL ,P-VERB .VAL>
				  ; "set P-ITBL[P-VERBN] = P-VTBL"
			      <PUT ,P-ITBL ,P-VERBN ,P-VTBL>
				  ; "set P-VTBL[0] = WRD"
			      <PUT ,P-VTBL 0 .WRD>
				  ; "set P-VTBL[2] = P-LEXV[CNT + (2 * PTR) + 2]"
			      <PUTB ,P-VTBL 2 <GETB ,P-LEXV
						    <SET CNT
							 <+ <* .PTR 2> 2>>>>
				  ; "set  P-VTBL[3] = P-LEXV[CNT + 1]"
			      <PUTB ,P-VTBL 3 <GETB ,P-LEXV <+ .CNT 1>>>)
				; "end of verb subcase"
				


				; "Next case:"
				; "If one of these is true:"
			   (<OR 
				  <SET VAL <WT? .WRD ,PS?PREPOSITION 0>>
					; "If WRD is ALL or WRD is ONE"
				  <EQUAL? .WRD ,W?ALL ,W?ONE ;,W?BOTH>
					; "Maybe: Is WRD an ADJECTIVE or OBJECT?"
				  <WT? .WRD ,PS?ADJECTIVE>
				  <WT? .WRD ,PS?OBJECT>>

				  ; "Then do this stuff:"
			      <COND 

							(<AND 
							; "P-LEN greater than 1"
							<G? ,P-LEN 1>
							; "NW equal to 'OF' (WHAT IS NW????)"
							<EQUAL? .NW ,W?OF>
							<ZERO? .VAL>
							; "WRD is not equal to ALL, ONE, or A"
							<NOT <EQUAL? .WRD
										,W?ALL ,W?ONE ,W?A>>
							;<NOT <EQUAL? .WRD ,W?BOTH>>>

							; "If all the above, then set OF-FLAG to T"
							; "T is usually a token, so not exactly sure what's happening
							   here"
							<SET OF-FLAG T>)

							; "Else if: "
							(
								; "If VAL !== ZERO"
								<AND <NOT <ZERO? .VAL>>
								    ; "If P-LEN == 0 || NW == THEN || NW == . "
										<OR <ZERO? ,P-LEN>
										   	<EQUAL? .NW ,W?THEN ,W?PERIOD>>>

							; "Then do:"
							<SETG P-END-ON-PREP T>
							<COND 
								; "If P-NCN < 2"
								(<L? ,P-NCN 2>

								; "Set the P-ITBL vals"
								<PUT ,P-ITBL ,P-PREP1 .VAL>
								<PUT ,P-ITBL ,P-PREP1N .WRD>)>)

							; "Bad speech case "
							(<EQUAL? ,P-NCN 2>
							<TELL
							"There were too many nouns in that sentence." CR>
							<RFALSE>) 

							; "Else case"
							(T
								<SETG P-NCN <+ ,P-NCN 1>>
								<SETG P-ACT .VERB>

								<OR <SET PTR <CLAUSE .PTR .VAL .WRD>>
										<RFALSE>>

								<COND (<L? .PTR 0>
									<SETG QUOTE-FLAG <>>
									<RETURN>)>)
						>)

				 ; "Next case:"
			     (<EQUAL? .WRD ,W?OF>
			   
				    <COND 
							(<OR <NOT .OF-FLAG>
									<EQUAL? .NW ,W?PERIOD ,W?THEN>>

							<CANT-USE .PTR>
							<RFALSE>)

							(T
							<SET OF-FLAG <>>)>)

				; "Next case: "
				  ;" Some kind of BUZZ WORD?"
			     (<WT? .WRD ,PS?BUZZ-WORD>)

				; "Next case: "
				; "Bad attempt to talk to something in the dungeon"
			     (<AND <EQUAL? .VERB ,ACT?TELL>
				   <WT? .WRD ,PS?VERB ,P1?VERB>
				   <EQUAL? ,WINNER ,PLAYER>>
			      <TELL
					"Please consult your manual for the correct way to talk to other people
					or creatures." CR>
			      <RFALSE>)

				; "Next case: "
			     (T
			      <CANT-USE .PTR>
			      <RFALSE>)
			>
		)
		; "End of The Word is Not NULL case "

    ; "Else case, I guess the word was NULL:"
		; "This is the case where we break out of the loop"
		; "And apparently the word reaches NULL, so we have made"
		; "our way through the input"
		(T
			<UNKNOWN-WORD .PTR>
			<RFALSE>)>
		; "End of mega COND"

		; "unconitionally: "
		; "Is LW last word?"
		<SET LW .WRD>
		<SET PTR <+ .PTR ,P-LEXELEN>>
		>
		)
		; "End of Big Fucking Loop"
		>

	<PUT ,OOPS-TABLE ,O-PTR <>>
	<COND (.DIR
	       <SETG PRSA ,V?WALK>
	       <SETG PRSO .DIR>
	       <SETG P-OFLAG <>>
	       <SETG P-WALK-DIR .DIR>
	       <SETG AGAIN-DIR .DIR>)
	      (ELSE
	       <COND (,P-OFLAG <ORPHAN-MERGE>)>
	       <SETG P-WALK-DIR <>>
	       <SETG AGAIN-DIR <>>
	       <COND (<AND <SYNTAX-CHECK>
			   <SNARF-OBJECTS>
			   <MANY-CHECK>
			   <TAKE-CHECK>>
		      T)>)>>

<GLOBAL P-ACT <>>
<GLOBAL P-WALK-DIR <>>
<GLOBAL AGAIN-DIR <>>

;"For AGAIN purposes, put contents of one LEXV table into another."
<ROUTINE STUFF (SRC DEST "OPTIONAL" (MAX 29) "AUX" (PTR ,P-LEXSTART) (CTR 1)
						   BPTR)
	 <PUTB .DEST 0 <GETB .SRC 0>>
	 <PUTB .DEST 1 <GETB .SRC 1>>
	 <REPEAT ()
	  <PUT .DEST .PTR <GET .SRC .PTR>>
	  <SET BPTR <+ <* .PTR 2> 2>>
	  <PUTB .DEST .BPTR <GETB .SRC .BPTR>>
	  <SET BPTR <+ <* .PTR 2> 3>>
	  <PUTB .DEST .BPTR <GETB .SRC .BPTR>>
	  <SET PTR <+ .PTR ,P-LEXELEN>>
	  <COND (<IGRTR? CTR .MAX>
		 <RETURN>)>>>

;"Put contents of one INBUF into another"
<ROUTINE INBUF-STUFF (SRC DEST "AUX" CNT)
	 <SET CNT <- <GETB .SRC 0> 1>>
	 <REPEAT ()
		 <PUTB .DEST .CNT <GETB .SRC .CNT>>
		 <COND (<DLESS? CNT 0> <RETURN>)>>>

;"Put the words in the positions specified from P-INBUF to the end of
OOPS-INBUF, leaving the appropriate pointers in AGAIN-LEXV"
<ROUTINE INBUF-ADD (LEN BEG SLOT "AUX" DBEG (CTR 0) TMP)
	 ; "start of COND"
	 <COND (
		 ; "If this is true ? "
		 ; "this sets TMP to whatever is at the end of the OOPS table
		    I presume"
		; "could be false if there is nothing at the end of the OOPS table ?"
		<SET TMP <GET ,OOPS-TABLE ,O-END>>
		; "set DBEG to the value of TMP"
		<SET DBEG .TMP>)

		; "the else case"
	  (T
		; "we want to set DBEG to (AGAIN-LEXV[OOPS-TABLE[O-LENGTH]] + AGAIN-LEXV[OOPS-TABLE[O-LENGTH + 1]])"
		<SET DBEG 
			<+ <GETB ,AGAIN-LEXV <SET TMP <GET ,OOPS-TABLE ,O-LENGTH>>>
			   <GETB ,AGAIN-LEXV <+ .TMP 1>>>
    >)
		>
	 ; "end of COND"

	; "set OOPS-TABLE[O-END] = DBEG + LEN"
	 <PUT ,OOPS-TABLE ,O-END <+ .DBEG .LEN>>

	; "a for loop, for ctr == len; ctr++"
	 <REPEAT ()
	 ; "set OOPS-INBUF[DBEG + CTR] = P-INBUF[BEG + CTR]"
	  <PUTB ,OOPS-INBUF <+ .DBEG .CTR> <GETB ,P-INBUF <+ .BEG .CTR>>>
		; "increment CTR"
	  <SET CTR <+ .CTR 1>>
		; "check if CTR == LEN"
	  <COND (<EQUAL? .CTR .LEN> <RETURN>)>>

	; "set AGAIN-LEXV[SLOT] = DBEG"
	 <PUTB ,AGAIN-LEXV .SLOT .DBEG>
	; "set AGAIN-LEXV[SLOT - 1] = len"
	 <PUTB ,AGAIN-LEXV <- .SLOT 1> .LEN>>
	 ; "end of ROUTINE"

;"Check whether word pointed at by PTR is the correct part of speech.
   The second argument is the part of speech (,PS?<part of speech>).  The
   3rd argument (,P1?<part of speech>), if given, causes the value
   for that part of speech to be returned."

<ROUTINE WT? (PTR BIT "OPTIONAL" (B1 5) "AUX" (OFFS ,P-P1OFF) TYP)
	<COND (<BTST <SET TYP <GETB .PTR ,P-PSOFF>> .BIT>
	       <COND (<G? .B1 4> <RTRUE>)
		     (T
		      <SET TYP <BAND .TYP ,P-P1BITS>>
		      <COND (<NOT <EQUAL? .TYP .B1>> <SET OFFS <+ .OFFS 1>>)>
		      <GETB .PTR .OFFS>)>)>>

;" Scan through a noun clause, leave a pointer to its starting location"

<ROUTINE CLAUSE (PTR VAL WRD "AUX" OFF NUM (ANDFLG <>) (FIRST?? T) NW (LW 0))
	<SET OFF <* <- ,P-NCN 1> 2>>
	<COND (<NOT <EQUAL? .VAL 0>>
	       <PUT ,P-ITBL <SET NUM <+ ,P-PREP1 .OFF>> .VAL>
	       <PUT ,P-ITBL <+ .NUM 1> .WRD>
	       <SET PTR <+ .PTR ,P-LEXELEN>>)
	      (T <SETG P-LEN <+ ,P-LEN 1>>)>
	<COND (<ZERO? ,P-LEN> <SETG P-NCN <- ,P-NCN 1>> <RETURN -1>)>
	<PUT ,P-ITBL <SET NUM <+ ,P-NC1 .OFF>> <REST ,P-LEXV <* .PTR 2>>>
	<COND (<EQUAL? <GET ,P-LEXV .PTR> ,W?THE ,W?A ,W?AN>
	       <PUT ,P-ITBL .NUM <REST <GET ,P-ITBL .NUM> 4>>)>
	<REPEAT ()
		<COND (<L? <SETG P-LEN <- ,P-LEN 1>> 0>
		       <PUT ,P-ITBL <+ .NUM 1> <REST ,P-LEXV <* .PTR 2>>>
		       <RETURN -1>)>
		<COND (<OR <SET WRD <GET ,P-LEXV .PTR>>
			   <SET WRD <NUMBER? .PTR>>>
		       <COND (<ZERO? ,P-LEN> <SET NW 0>)
			     (T <SET NW <GET ,P-LEXV <+ .PTR ,P-LEXELEN>>>)>
		       <COND (<EQUAL? .WRD ,W?AND ,W?COMMA> <SET ANDFLG T>)
			     (<EQUAL? .WRD ,W?ALL ,W?ONE ;,W?BOTH>
			      <COND (<EQUAL? .NW ,W?OF>
				     <SETG P-LEN <- ,P-LEN 1>>
				     <SET PTR <+ .PTR ,P-LEXELEN>>)>)
			     (<OR <EQUAL? .WRD ,W?THEN ,W?PERIOD>
				  <AND <WT? .WRD ,PS?PREPOSITION>
				       <GET ,P-ITBL ,P-VERB>
				          ;"ADDED 4/27 FOR TURTLE,UP"
				       <NOT .FIRST??>>>
			      <SETG P-LEN <+ ,P-LEN 1>>
			      <PUT ,P-ITBL
				   <+ .NUM 1>
				   <REST ,P-LEXV <* .PTR 2>>>
			      <RETURN <- .PTR ,P-LEXELEN>>)
			     (<WT? .WRD ,PS?OBJECT>
			      <COND (<AND <G? ,P-LEN 0>
					  <EQUAL? .NW ,W?OF>
					  <NOT <EQUAL? .WRD ,W?ALL ,W?ONE>>>
				     T)
				    (<AND <WT? .WRD
					       ,PS?ADJECTIVE
					       ,P1?ADJECTIVE>
					  <NOT <EQUAL? .NW 0>>
					  <WT? .NW ,PS?OBJECT>>)
				    (<AND <NOT .ANDFLG>
					  <NOT <EQUAL? .NW ,W?BUT ,W?EXCEPT>>
					  <NOT <EQUAL? .NW ,W?AND ,W?COMMA>>>
				     <PUT ,P-ITBL
					  <+ .NUM 1>
					  <REST ,P-LEXV <* <+ .PTR 2> 2>>>
				     <RETURN .PTR>)
				    (T <SET ANDFLG <>>)>)
			     (<AND <OR ,P-MERGED
				       ,P-OFLAG
				       <NOT <EQUAL? <GET ,P-ITBL ,P-VERB> 0>>>
				   <OR <WT? .WRD ,PS?ADJECTIVE>
				       <WT? .WRD ,PS?BUZZ-WORD>>>)
			     (<AND .ANDFLG
				   <OR <WT? .WRD ,PS?DIRECTION>
				       <WT? .WRD ,PS?VERB>>>
			      <SET PTR <- .PTR 4>>
			      <PUT ,P-LEXV <+ .PTR 2> ,W?THEN>
			      <SETG P-LEN <+ ,P-LEN 2>>)
			     (<WT? .WRD ,PS?PREPOSITION> T)
			     (T
			      <CANT-USE .PTR>
			      <RFALSE>)>)
		      (T <UNKNOWN-WORD .PTR> <RFALSE>)>
		<SET LW .WRD>
		<SET FIRST?? <>>
		<SET PTR <+ .PTR ,P-LEXELEN>>>>

<ROUTINE NUMBER? (PTR "AUX" CNT BPTR CHR (SUM 0) (TIM <>))
	 <SET CNT <GETB <REST ,P-LEXV <* .PTR 2>> 2>>
	 <SET BPTR <GETB <REST ,P-LEXV <* .PTR 2>> 3>>
	 <REPEAT ()
		 <COND (<L? <SET CNT <- .CNT 1>> 0> <RETURN>)
		       (T
			<SET CHR <GETB ,P-INBUF .BPTR>>
			<COND (<EQUAL? .CHR 58>
			       <SET TIM .SUM>
			       <SET SUM 0>)
			      (<G? .SUM 10000> <RFALSE>)
			      (<AND <L? .CHR 58> <G? .CHR 47>>
			       <SET SUM <+ <* .SUM 10> <- .CHR 48>>>)
			      (T <RFALSE>)>
			<SET BPTR <+ .BPTR 1>>)>>
	 <PUT ,P-LEXV .PTR ,W?INTNUM>
	 <COND (<G? .SUM 1000> <RFALSE>)
	       (.TIM
		<COND (<L? .TIM 8> <SET TIM <+ .TIM 12>>)
		      (<G? .TIM 23> <RFALSE>)>
		<SET SUM <+ .SUM <* .TIM 60>>>)>
	 <SETG P-NUMBER .SUM>
	 ,W?INTNUM>

<GLOBAL P-NUMBER 0>

<GLOBAL P-DIRECTION 0>


;"New ORPHAN-MERGE for TRAP Retrofix 6/21/84"

<ROUTINE ORPHAN-MERGE ("AUX" (CNT -1) TEMP VERB BEG END (ADJ <>) WRD)
   <SETG P-OFLAG <>>
   <COND (<OR <EQUAL? <WT? <SET WRD <GET <GET ,P-ITBL ,P-VERBN> 0>>
			   ,PS?VERB ,P1?VERB>
		      <GET ,P-OTBL ,P-VERB>>
	      <NOT <ZERO? <WT? .WRD ,PS?ADJECTIVE>>>>
	  <SET ADJ T>)
	 (<AND <NOT <ZERO? <WT? .WRD ,PS?OBJECT ,P1?OBJECT>>>
	       <EQUAL? ,P-NCN 0>>
	  <PUT ,P-ITBL ,P-VERB 0>
	  <PUT ,P-ITBL ,P-VERBN 0>
	  <PUT ,P-ITBL ,P-NC1 <REST ,P-LEXV 2>>
	  <PUT ,P-ITBL ,P-NC1L <REST ,P-LEXV 6>>
	  <SETG P-NCN 1>)>
   <COND (<AND <NOT <ZERO? <SET VERB <GET ,P-ITBL ,P-VERB>>>>
	       <NOT .ADJ>
	       <NOT <EQUAL? .VERB <GET ,P-OTBL ,P-VERB>>>>
	  <RFALSE>)
	 (<EQUAL? ,P-NCN 2> <RFALSE>)
	 (<EQUAL? <GET ,P-OTBL ,P-NC1> 1>
	  <COND (<OR <EQUAL? <SET TEMP <GET ,P-ITBL ,P-PREP1>>
			  <GET ,P-OTBL ,P-PREP1>>
		     <ZERO? .TEMP>>
		 <COND (.ADJ
			<PUT ,P-OTBL ,P-NC1 <REST ,P-LEXV 2>>
			<COND (<ZERO? <GET ,P-ITBL ,P-NC1L>>
			       <PUT ,P-ITBL ,P-NC1L <REST ,P-LEXV 6>>)>
			<COND (<ZERO? ,P-NCN> <SETG P-NCN 1>)>)
		       (T
			<PUT ,P-OTBL ,P-NC1 <GET ,P-ITBL ,P-NC1>>)>
		 <PUT ,P-OTBL ,P-NC1L <GET ,P-ITBL ,P-NC1L>>)
		(T <RFALSE>)>)
	 (<EQUAL? <GET ,P-OTBL ,P-NC2> 1>
	  <COND (<OR <EQUAL? <SET TEMP <GET ,P-ITBL ,P-PREP1>>
			  <GET ,P-OTBL ,P-PREP2>>
		     <ZERO? .TEMP>>
		 <COND (.ADJ
			<PUT ,P-ITBL ,P-NC1 <REST ,P-LEXV 2>>
			<COND (<ZERO? <GET ,P-ITBL ,P-NC1L>>
			       <PUT ,P-ITBL ,P-NC1L <REST ,P-LEXV 6>>)>)>
		 <PUT ,P-OTBL ,P-NC2 <GET ,P-ITBL ,P-NC1>>
		 <PUT ,P-OTBL ,P-NC2L <GET ,P-ITBL ,P-NC1L>>
		 <SETG P-NCN 2>)
		(T <RFALSE>)>)
	 (<NOT <ZERO? ,P-ACLAUSE>>
	  <COND (<AND <NOT <EQUAL? ,P-NCN 1>> <NOT .ADJ>>
		 <SETG P-ACLAUSE <>>
		 <RFALSE>)
		(T
		 <SET BEG <GET ,P-ITBL ,P-NC1>>
		 <COND (.ADJ <SET BEG <REST ,P-LEXV 2>> <SET ADJ <>>)>
		 <SET END <GET ,P-ITBL ,P-NC1L>>
		 <REPEAT ()
			 <SET WRD <GET .BEG 0>>
			 <COND (<EQUAL? .BEG .END>
				<COND (.ADJ <ACLAUSE-WIN .ADJ> <RETURN>)
				      (T <SETG P-ACLAUSE <>> <RFALSE>)>)
			       (<AND <NOT .ADJ>
				     <OR <BTST <GETB .WRD ,P-PSOFF>
					       ,PS?ADJECTIVE>
					 <EQUAL? .WRD ,W?ALL ,W?ONE>>>
				<SET ADJ .WRD>)
			       (<EQUAL? .WRD ,W?ONE>
				<ACLAUSE-WIN .ADJ>
				<RETURN>)
			       (<BTST <GETB .WRD ,P-PSOFF> ,PS?OBJECT>
				<COND (<EQUAL? .WRD ,P-ANAM>
				       <ACLAUSE-WIN .ADJ>)
				      (T
				       <NCLAUSE-WIN>)>
				<RETURN>)>
			 <SET BEG <REST .BEG ,P-WORDLEN>>
			 <COND (<EQUAL? .END 0>
				<SET END .BEG>
				<SETG P-NCN 1>
				<PUT ,P-ITBL ,P-NC1 <BACK .BEG 4>>
				<PUT ,P-ITBL ,P-NC1L .BEG>)>>)>)>
   <PUT ,P-VTBL 0 <GET ,P-OVTBL 0>>
   <PUTB ,P-VTBL 2 <GETB ,P-OVTBL 2>>
   <PUTB ,P-VTBL 3 <GETB ,P-OVTBL 3>>
   <PUT ,P-OTBL ,P-VERBN ,P-VTBL>
   <PUTB ,P-VTBL 2 0>
   <REPEAT ()
	   <COND (<G? <SET CNT <+ .CNT 1>> ,P-ITBLLEN>
		  <SETG P-MERGED T>
		  <RTRUE>)
		 (T <PUT ,P-ITBL .CNT <GET ,P-OTBL .CNT>>)>>
   T>

;"New ACLAUSE-WIN for TRAP retrofix 6/21/84"

<ROUTINE ACLAUSE-WIN (ADJ)
	<PUT ,P-ITBL ,P-VERB <GET ,P-OTBL ,P-VERB>>
	<PUT ,P-CCTBL ,CC-SBPTR ,P-ACLAUSE>
	<PUT ,P-CCTBL ,CC-SEPTR <+ ,P-ACLAUSE 1>>
	<PUT ,P-CCTBL ,CC-DBPTR ,P-ACLAUSE>
	<PUT ,P-CCTBL ,CC-DEPTR <+ ,P-ACLAUSE 1>>
	<CLAUSE-COPY ,P-OTBL ,P-OTBL .ADJ>
	<AND <NOT <EQUAL? <GET ,P-OTBL ,P-NC2> 0>> <SETG P-NCN 2>>
	<SETG P-ACLAUSE <>>
	<RTRUE>>

<ROUTINE NCLAUSE-WIN ()
        <PUT ,P-CCTBL ,CC-SBPTR ,P-NC1>
	<PUT ,P-CCTBL ,CC-SEPTR ,P-NC1L>
	<PUT ,P-CCTBL ,CC-DBPTR ,P-ACLAUSE>
	<PUT ,P-CCTBL ,CC-DEPTR <+ ,P-ACLAUSE 1>>
	<CLAUSE-COPY ,P-ITBL ,P-OTBL>
	<AND <NOT <EQUAL? <GET ,P-OTBL ,P-NC2> 0>> <SETG P-NCN 2>>
	<SETG P-ACLAUSE <>>
	<RTRUE>>

;"Print undefined word in input.
   PTR points to the unknown word in P-LEXV"

<ROUTINE WORD-PRINT (CNT BUF)
	 <REPEAT ()
		 <COND (<DLESS? CNT 0> <RETURN>)
		       (ELSE
			<PRINTC <GETB ,P-INBUF .BUF>>
			<SET BUF <+ .BUF 1>>)>>>

<ROUTINE UNKNOWN-WORD (PTR "AUX" BUF)
	<PUT ,OOPS-TABLE ,O-PTR .PTR>
	<COND (<VERB? SAY>
	       <TELL "Nothing happens." CR>
	       <RFALSE>)>
	<TELL "I don't know the word \"">
	<WORD-PRINT <GETB <REST ,P-LEXV <SET BUF <* .PTR 2>>> 2>
		    <GETB <REST ,P-LEXV .BUF> 3>>
	<TELL "\"." CR>
	<SETG QUOTE-FLAG <>>
	<SETG P-OFLAG <>>>

<ROUTINE CANT-USE (PTR "AUX" BUF)
	<COND (<VERB? SAY>
	       <TELL "Nothing happens." CR>
	       <RFALSE>)>
	<TELL "You used the word \"">
	<WORD-PRINT <GETB <REST ,P-LEXV <SET BUF <* .PTR 2>>> 2>
		    <GETB <REST ,P-LEXV .BUF> 3>>
	<TELL "\" in a way that I don't understand." CR>
	<SETG QUOTE-FLAG <>>
	<SETG P-OFLAG <>>>

;" Perform syntax matching operations, using P-ITBL as the source of
   the verb and adjectives for this input.  Returns false if no
   syntax matches, and does it's own orphaning.  If return is true,
   the syntax is saved in P-SYNTAX."

<GLOBAL P-SLOCBITS 0>

<CONSTANT P-SYNLEN 8>

<CONSTANT P-SBITS 0>
<CONSTANT P-SPREP1 1>
<CONSTANT P-SPREP2 2>
<CONSTANT P-SFWIM1 3>
<CONSTANT P-SFWIM2 4>
<CONSTANT P-SLOC1 5>
<CONSTANT P-SLOC2 6>
<CONSTANT P-SACTION 7>
<CONSTANT P-SONUMS 3>

<ROUTINE SYNTAX-CHECK ("AUX" SYN LEN NUM OBJ
		       	    (DRIVE1 <>) (DRIVE2 <>) PREP VERB TMP)
	<COND (<ZERO? <SET VERB <GET ,P-ITBL ,P-VERB>>>
	       <TELL "There was no verb in that sentence!" CR>
	       <RFALSE>)>
	<SET SYN <GET ,VERBS <- 255 .VERB>>>
	<SET LEN <GETB .SYN 0>>
	<SET SYN <REST .SYN>>
	<REPEAT ()
		<SET NUM <BAND <GETB .SYN ,P-SBITS> ,P-SONUMS>>
		<COND (<G? ,P-NCN .NUM> T)
		      (<AND <NOT <L? .NUM 1>>
			    <ZERO? ,P-NCN>
			    <OR <ZERO? <SET PREP <GET ,P-ITBL ,P-PREP1>>>
				<EQUAL? .PREP <GETB .SYN ,P-SPREP1>>>>
		       <SET DRIVE1 .SYN>)
		      (<EQUAL? <GETB .SYN ,P-SPREP1> <GET ,P-ITBL ,P-PREP1>>
		       <COND (<AND <EQUAL? .NUM 2> <EQUAL? ,P-NCN 1>>
			      <SET DRIVE2 .SYN>)
			     (<EQUAL? <GETB .SYN ,P-SPREP2>
				   <GET ,P-ITBL ,P-PREP2>>
			      <SYNTAX-FOUND .SYN>
			      <RTRUE>)>)>
		<COND (<DLESS? LEN 1>
		       <COND (<OR .DRIVE1 .DRIVE2> <RETURN>)
			     (T
			      <TELL
"That sentence isn't one I recognize." CR>
			      <RFALSE>)>)
		      (T <SET SYN <REST .SYN ,P-SYNLEN>>)>>
	<COND (<AND .DRIVE1
		    <SET OBJ
			 <GWIM <GETB .DRIVE1 ,P-SFWIM1>
			       <GETB .DRIVE1 ,P-SLOC1>
			       <GETB .DRIVE1 ,P-SPREP1>>>>
	       <PUT ,P-PRSO ,P-MATCHLEN 1>
	       <PUT ,P-PRSO 1 .OBJ>
	       <SYNTAX-FOUND .DRIVE1>)
	      (<AND .DRIVE2
		    <SET OBJ
			 <GWIM <GETB .DRIVE2 ,P-SFWIM2>
			       <GETB .DRIVE2 ,P-SLOC2>
			       <GETB .DRIVE2 ,P-SPREP2>>>>
	       <PUT ,P-PRSI ,P-MATCHLEN 1>
	       <PUT ,P-PRSI 1 .OBJ>
	       <SYNTAX-FOUND .DRIVE2>)
	      (<EQUAL? .VERB ,ACT?FIND>
	       <TELL "That question can't be answered." CR>
	       <RFALSE>)
	      (<NOT <EQUAL? ,WINNER ,PLAYER>>
	       <CANT-ORPHAN>)
	      (T
	       <ORPHAN .DRIVE1 .DRIVE2>
	       <TELL "What do you want to ">
	       <SET TMP <GET ,P-OTBL ,P-VERBN>>
	       <COND (<EQUAL? .TMP 0> <TELL "tell">)
		     (<ZERO? <GETB ,P-VTBL 2>>
		      <PRINTB <GET .TMP 0>>)
		     (T
		      <WORD-PRINT <GETB .TMP 2> <GETB .TMP 3>>
		      <PUTB ,P-VTBL 2 0>)>
	       <COND (.DRIVE2
		      <TELL " ">
		      <THING-PRINT T T>)>
	       <SETG P-OFLAG T>
	       <PREP-PRINT <COND (.DRIVE1 <GETB .DRIVE1 ,P-SPREP1>)
				 (T <GETB .DRIVE2 ,P-SPREP2>)>>
	       <TELL "?" CR>
	       <RFALSE>)>>

<ROUTINE CANT-ORPHAN ()
	 <TELL "\"I don't understand! What are you referring to?\"" CR>
	 <RFALSE>>


<ROUTINE ORPHAN (D1 D2 "AUX" (CNT -1))
	<COND (<NOT ,P-MERGED>
	       <PUT ,P-OCLAUSE ,P-MATCHLEN 0>)>
	<PUT ,P-OVTBL 0 <GET ,P-VTBL 0>>
	<PUTB ,P-OVTBL 2 <GETB ,P-VTBL 2>>
	<PUTB ,P-OVTBL 3 <GETB ,P-VTBL 3>>
	<REPEAT ()
		<COND (<IGRTR? CNT ,P-ITBLLEN> <RETURN>)
		      (T <PUT ,P-OTBL .CNT <GET ,P-ITBL .CNT>>)>>
	<COND (<EQUAL? ,P-NCN 2>
	       <PUT ,P-CCTBL ,CC-SBPTR ,P-NC2>
	       <PUT ,P-CCTBL ,CC-SEPTR ,P-NC2L>
	       <PUT ,P-CCTBL ,CC-DBPTR ,P-NC2>
	       <PUT ,P-CCTBL ,CC-DEPTR ,P-NC2L>
	       <CLAUSE-COPY ,P-ITBL ,P-OTBL>)>
	<COND (<NOT <L? ,P-NCN 1>>
	       <PUT ,P-CCTBL ,CC-SBPTR ,P-NC1>
	       <PUT ,P-CCTBL ,CC-SEPTR ,P-NC1L>
	       <PUT ,P-CCTBL ,CC-DBPTR ,P-NC1>
	       <PUT ,P-CCTBL ,CC-DEPTR ,P-NC1L>
	       <CLAUSE-COPY ,P-ITBL ,P-OTBL>)>
	<COND (.D1
	       <PUT ,P-OTBL ,P-PREP1 <GETB .D1 ,P-SPREP1>>
	       <PUT ,P-OTBL ,P-NC1 1>)
	      (.D2
	       <PUT ,P-OTBL ,P-PREP2 <GETB .D2 ,P-SPREP2>>
	       <PUT ,P-OTBL ,P-NC2 1>)>>

<ROUTINE THING-PRINT (PRSO? "OPTIONAL" (THE? <>) "AUX" BEG END)
	 <COND (.PRSO?
		<SET BEG <GET ,P-ITBL ,P-NC1>>
		<SET END <GET ,P-ITBL ,P-NC1L>>)
	       (ELSE
		<SET BEG <GET ,P-ITBL ,P-NC2>>
		<SET END <GET ,P-ITBL ,P-NC2L>>)>
	 <BUFFER-PRINT .BEG .END .THE?>>

<ROUTINE BUFFER-PRINT (BEG END CP
		       "AUX" (NOSP T) WRD (FIRST?? T) (PN <>) (Q? <>))
	 <REPEAT ()
		<COND (<EQUAL? .BEG .END> <RETURN>)
		      (T
		       <SET WRD <GET .BEG 0>>
		       <COND ;(<EQUAL? .WRD ,W?$BUZZ> T)
			     (<EQUAL? .WRD ,W?COMMA>
			      <TELL ", ">)
			     (.NOSP <SET NOSP <>>)
			     (ELSE <TELL " ">)>
		       <COND (<EQUAL? .WRD ,W?PERIOD ,W?COMMA>
			      <SET NOSP T>)
			     (<EQUAL? .WRD ,W?ME>
			      <PRINTD ,ME>
			      <SET PN T>)
			     (<EQUAL? .WRD ,W?INTNUM>
			      <PRINTN ,P-NUMBER>
			      <SET PN T>)
			     (T
			      <COND (<AND .FIRST?? <NOT .PN> .CP>
				     <TELL "the ">)>
			      <COND (<OR ,P-OFLAG ,P-MERGED> <PRINTB .WRD>)
				    (<AND <EQUAL? .WRD ,W?IT>
					  <ACCESSIBLE? ,P-IT-OBJECT>>
				     <PRINTD ,P-IT-OBJECT>)
				    (T
				     <WORD-PRINT <GETB .BEG 2>
						 <GETB .BEG 3>>)>
			      <SET FIRST?? <>>)>)>
		<SET BEG <REST .BEG ,P-WORDLEN>>>>

<ROUTINE PREP-PRINT (PREP "AUX" WRD)
	<COND (<NOT <ZERO? .PREP>>
	       <TELL " ">
	       <COND ;(<EQUAL? .PREP ,PR?THROUGH>
		      <TELL "through">)
		     (T
		      <SET WRD <PREP-FIND .PREP>>
		      <PRINTB .WRD>)>)>>

<ROUTINE CLAUSE-COPY (SRC DEST "OPTIONAL" (INSRT <>) "AUX" BEG END)
	<SET BEG <GET .SRC <GET ,P-CCTBL ,CC-SBPTR>>>
	<SET END <GET .SRC <GET ,P-CCTBL ,CC-SEPTR>>>
	<PUT .DEST
	     <GET ,P-CCTBL ,CC-DBPTR>
	     <REST ,P-OCLAUSE
		   <+ <* <GET ,P-OCLAUSE ,P-MATCHLEN> ,P-LEXELEN> 2>>>
	<REPEAT ()
		<COND (<EQUAL? .BEG .END>
		       <PUT .DEST
			    <GET ,P-CCTBL ,CC-DEPTR>
			    <REST ,P-OCLAUSE
				  <+ <* <GET ,P-OCLAUSE ,P-MATCHLEN> ,P-LEXELEN>
				     2>>>
		       <RETURN>)
		      (T
		       <COND (<AND .INSRT <EQUAL? ,P-ANAM <GET .BEG 0>>>
			      <CLAUSE-ADD .INSRT>)>
		       <CLAUSE-ADD <GET .BEG 0>>)>
		<SET BEG <REST .BEG ,P-WORDLEN>>>>


<ROUTINE CLAUSE-ADD (WRD "AUX" PTR)
	<SET PTR <+ <GET ,P-OCLAUSE ,P-MATCHLEN> 2>>
	<PUT ,P-OCLAUSE <- .PTR 1> .WRD>
	<PUT ,P-OCLAUSE .PTR 0>
	<PUT ,P-OCLAUSE ,P-MATCHLEN .PTR>>

<ROUTINE PREP-FIND (PREP "AUX" (CNT 0) SIZE)
	<SET SIZE <* <GET ,PREPOSITIONS 0> 2>>
	<REPEAT ()
		<COND (<IGRTR? CNT .SIZE> <RFALSE>)
		      (<EQUAL? <GET ,PREPOSITIONS .CNT> .PREP>
		       <RETURN <GET ,PREPOSITIONS <- .CNT 1>>>)>>>

<ROUTINE SYNTAX-FOUND (SYN)
	<SETG P-SYNTAX .SYN>
	<SETG PRSA <GETB .SYN ,P-SACTION>>>

<GLOBAL P-GWIMBIT 0>

<ROUTINE GWIM (GBIT LBIT PREP "AUX" OBJ)
	<COND (<EQUAL? .GBIT ,RMUNGBIT>
	       <RETURN ,ROOMS>)>
	<SETG P-GWIMBIT .GBIT>
	<SETG P-SLOCBITS .LBIT>
	<PUT ,P-MERGE ,P-MATCHLEN 0>
	<COND (<GET-OBJECT ,P-MERGE <>>
	       <SETG P-GWIMBIT 0>
	       <COND (<EQUAL? <GET ,P-MERGE ,P-MATCHLEN> 1>
		      <SET OBJ <GET ,P-MERGE 1>>
		      <TELL "(">
		      <COND (<AND <NOT <ZERO? .PREP>>
				  <NOT ,P-END-ON-PREP>>
			     <PRINTB <SET PREP <PREP-FIND .PREP>>>
			     <COND (<EQUAL? .PREP ,W?OUT>
				    <TELL " of">)>
			     <TELL " ">
			     <COND (<EQUAL? .OBJ ,HANDS>
				    <TELL "your hands">)
				   (T
				    <TELL "the " D .OBJ>)>
			     <TELL ")" CR>)
			    (ELSE
			     <TELL D .OBJ ")" CR>)>
		      .OBJ)>)
	      (T <SETG P-GWIMBIT 0> <RFALSE>)>>

<ROUTINE SNARF-OBJECTS ("AUX" OPTR IPTR L)
	 <PUT ,P-BUTS ,P-MATCHLEN 0>
	 <COND (<NOT <EQUAL? <SET IPTR <GET ,P-ITBL ,P-NC2>> 0>>
		<SETG P-SLOCBITS <GETB ,P-SYNTAX ,P-SLOC2>>
		<OR <SNARFEM .IPTR <GET ,P-ITBL ,P-NC2L> ,P-PRSI> <RFALSE>>)>
	 <COND (<NOT <EQUAL? <SET OPTR <GET ,P-ITBL ,P-NC1>> 0>>
		<SETG P-SLOCBITS <GETB ,P-SYNTAX ,P-SLOC1>>
		<OR <SNARFEM .OPTR <GET ,P-ITBL ,P-NC1L> ,P-PRSO> <RFALSE>>)>
	 <COND (<NOT <ZERO? <GET ,P-BUTS ,P-MATCHLEN>>>
		<SET L <GET ,P-PRSO ,P-MATCHLEN>>
		<COND (.OPTR <SETG P-PRSO <BUT-MERGE ,P-PRSO>>)>
		<COND (<AND .IPTR
			    <OR <NOT .OPTR>
				<EQUAL? .L <GET ,P-PRSO ,P-MATCHLEN>>>>
		       <SETG P-PRSI <BUT-MERGE ,P-PRSI>>)>)>
	 <RTRUE>>

<ROUTINE BUT-MERGE (TBL "AUX" LEN BUTLEN (CNT 1) (MATCHES 0) OBJ NTBL)
	<SET LEN <GET .TBL ,P-MATCHLEN>>
	<PUT ,P-MERGE ,P-MATCHLEN 0>
	<REPEAT ()
		<COND (<DLESS? LEN 0> <RETURN>)
		      (<ZMEMQ <SET OBJ <GET .TBL .CNT>> ,P-BUTS>)
		      (T
		       <PUT ,P-MERGE <+ .MATCHES 1> .OBJ>
		       <SET MATCHES <+ .MATCHES 1>>)>
		<SET CNT <+ .CNT 1>>>
	<PUT ,P-MERGE ,P-MATCHLEN .MATCHES>
	<SET NTBL ,P-MERGE>
	<SETG P-MERGE .TBL>
	.NTBL>

<GLOBAL P-NAM <>>
<GLOBAL P-ADJ <>>
<GLOBAL P-ADVERB <>>
<GLOBAL P-ADJN <>>
<GLOBAL P-PRSO <ITABLE NONE 50>>
<GLOBAL P-PRSI <ITABLE NONE 50>>
<GLOBAL P-BUTS <ITABLE NONE 50>>
<GLOBAL P-MERGE <ITABLE NONE 50>>
<GLOBAL P-OCLAUSE <ITABLE NONE 100>>
<GLOBAL P-MATCHLEN 0>
<GLOBAL P-GETFLAGS 0>
<CONSTANT P-ALL 1>
<CONSTANT P-ONE 2>
<CONSTANT P-INHIBIT 4>


<GLOBAL P-AND <>>

<ROUTINE SNARFEM (PTR EPTR TBL "AUX" (BUT <>) LEN WV WRD NW (WAS-ALL <>))
   <SETG P-AND <>>
   <COND (<EQUAL? ,P-GETFLAGS ,P-ALL>
	  <SET WAS-ALL T>)>
   <SETG P-GETFLAGS 0>
   <PUT .TBL ,P-MATCHLEN 0>
   <SET WRD <GET .PTR 0>>
   <REPEAT ()
	   <COND (<EQUAL? .PTR .EPTR>
		  <SET WV <GET-OBJECT <OR .BUT .TBL>>>
		  <COND (.WAS-ALL <SETG P-GETFLAGS ,P-ALL>)>
		  <RETURN .WV>)
		 (T
		  <COND (<==? .EPTR <REST .PTR ,P-WORDLEN>>
			 <SET NW 0>)
			(T <SET NW <GET .PTR ,P-LEXELEN>>)>
		  <COND (<EQUAL? .WRD ,W?ALL ;,W?BOTH>
			 <SETG P-GETFLAGS ,P-ALL>
			 <COND (<EQUAL? .NW ,W?OF>
				<SET PTR <REST .PTR ,P-WORDLEN>>)>)
			(<EQUAL? .WRD ,W?BUT ,W?EXCEPT>
			 <OR <GET-OBJECT <OR .BUT .TBL>> <RFALSE>>
			 <SET BUT ,P-BUTS>
			 <PUT .BUT ,P-MATCHLEN 0>)
			(<EQUAL? .WRD ,W?A ,W?ONE>
			 <COND (<NOT ,P-ADJ>
				<SETG P-GETFLAGS ,P-ONE>
				<COND (<EQUAL? .NW ,W?OF>
				       <SET PTR <REST .PTR ,P-WORDLEN>>)>)
			       (T
				<SETG P-NAM ,P-ONEOBJ>
				<OR <GET-OBJECT <OR .BUT .TBL>> <RFALSE>>
				<AND <ZERO? .NW> <RTRUE>>)>)
			(<AND <EQUAL? .WRD ,W?AND ,W?COMMA>
			      <NOT <EQUAL? .NW ,W?AND ,W?COMMA>>>
			 <SETG P-AND T>
			 <OR <GET-OBJECT <OR .BUT .TBL>> <RFALSE>>
			 T)
			(<WT? .WRD ,PS?BUZZ-WORD>)
			(<EQUAL? .WRD ,W?AND ,W?COMMA>)
			(<EQUAL? .WRD ,W?OF>
			 <COND (<ZERO? ,P-GETFLAGS>
				<SETG P-GETFLAGS ,P-INHIBIT>)>)
			(<AND <SET WV <WT? .WRD ,PS?ADJECTIVE ,P1?ADJECTIVE>>
			      <NOT ,P-ADJ>>
			 <SETG P-ADJ .WV>
			 <SETG P-ADJN .WRD>)
			(<WT? .WRD ,PS?OBJECT ,P1?OBJECT>
			 <SETG P-NAM .WRD>
			 <SETG P-ONEOBJ .WRD>)>)>
	   <COND (<NOT <EQUAL? .PTR .EPTR>>
		  <SET PTR <REST .PTR ,P-WORDLEN>>
		  <SET WRD .NW>)>>>

<CONSTANT SH 128>
<CONSTANT SC 64>
<CONSTANT SIR 32>
<CONSTANT SOG 16>
<CONSTANT STAKE 8>
<CONSTANT SMANY 4>
<CONSTANT SHAVE 2>

<ROUTINE GET-OBJECT (TBL
		     "OPTIONAL" (VRB T)
		     "AUX" BITS LEN XBITS TLEN (GCHECK <>) (OLEN 0) OBJ)
	 <SET XBITS ,P-SLOCBITS>
	 <SET TLEN <GET .TBL ,P-MATCHLEN>>
	 <COND (<BTST ,P-GETFLAGS ,P-INHIBIT> <RTRUE>)>
	 <COND (<AND <NOT ,P-NAM> ,P-ADJ>
		<COND (<WT? ,P-ADJN ,PS?OBJECT ,P1?OBJECT>
		       <SETG P-NAM ,P-ADJN>
		       <SETG P-ADJ <>>)
		      %<COND (<==? ,ZORK-NUMBER 3>
			      '(<SET BITS
				     <WT? ,P-ADJN
					  ,PS?DIRECTION ,P1?DIRECTION>>
				<SETG P-ADJ <>>
				<PUT .TBL ,P-MATCHLEN 1>
				<PUT .TBL 1 ,INTDIR>
				<SETG P-DIRECTION .BITS>
				<RTRUE>))
			     (ELSE '(<NULL-F> T))>>)>
	 <COND (<AND <NOT ,P-NAM>
		     <NOT ,P-ADJ>
		     <NOT <EQUAL? ,P-GETFLAGS ,P-ALL>>
		     <ZERO? ,P-GWIMBIT>>
		<COND (.VRB
		       <TELL
"There seems to be a noun missing in that sentence!" CR>)>
		<RFALSE>)>
	 <COND (<OR <NOT <EQUAL? ,P-GETFLAGS ,P-ALL>> <ZERO? ,P-SLOCBITS>>
		<SETG P-SLOCBITS -1>)>
	 <SETG P-TABLE .TBL>
	 <PROG ()
	       <COND (.GCHECK <GLOBAL-CHECK .TBL>)
		     (T
		      <COND (,LIT
			     <FCLEAR ,PLAYER ,TRANSBIT>
			     <DO-SL ,HERE ,SOG ,SIR>
			     <FSET ,PLAYER ,TRANSBIT>)>
		      <DO-SL ,PLAYER ,SH ,SC>)>
	       <SET LEN <- <GET .TBL ,P-MATCHLEN> .TLEN>>
	       <COND (<BTST ,P-GETFLAGS ,P-ALL>)
		     (<AND <BTST ,P-GETFLAGS ,P-ONE>
			   <NOT <ZERO? .LEN>>>
		      <COND (<NOT <EQUAL? .LEN 1>>
			     <PUT .TBL 1 <GET .TBL <RANDOM .LEN>>>
			     <TELL "(How about the ">
			     <PRINTD <GET .TBL 1>>
			     <TELL "?)" CR>)>
		      <PUT .TBL ,P-MATCHLEN 1>)
		     (<OR <G? .LEN 1>
			  <AND <ZERO? .LEN> <NOT <EQUAL? ,P-SLOCBITS -1>>>>
		      <COND (<EQUAL? ,P-SLOCBITS -1>
			     <SETG P-SLOCBITS .XBITS>
			     <SET OLEN .LEN>
			     <PUT .TBL
				  ,P-MATCHLEN
				  <- <GET .TBL ,P-MATCHLEN> .LEN>>
			     <AGAIN>)
			    (T
			     <COND (<ZERO? .LEN> <SET LEN .OLEN>)>
			     <COND (<NOT <EQUAL? ,WINNER ,PLAYER>>
				    <CANT-ORPHAN>
				    <RFALSE>)
				   (<AND .VRB ,P-NAM>
				    <WHICH-PRINT .TLEN .LEN .TBL>
				    <SETG P-ACLAUSE
					  <COND (<EQUAL? .TBL ,P-PRSO> ,P-NC1)
						(T ,P-NC2)>>
				    <SETG P-AADJ ,P-ADJ>
				    <SETG P-ANAM ,P-NAM>
				    <ORPHAN <> <>>
				    <SETG P-OFLAG T>)
				   (.VRB
				    <TELL
"There seems to be a noun missing in that sentence!" CR>)>
			     <SETG P-NAM <>>
			     <SETG P-ADJ <>>
			     <RFALSE>)>)>
	       <COND (<AND <ZERO? .LEN> .GCHECK>
		      <COND (.VRB
			     ;"next added 1/2/85 by JW"
			     <SETG P-SLOCBITS .XBITS>
			     <COND (<OR ,LIT <VERB? TELL ;WHERE ;WHAT ;WHO>>
				    ;"Changed 6/10/83 - MARC"
				    <OBJ-FOUND ,NOT-HERE-OBJECT .TBL>
				    <SETG P-XNAM ,P-NAM>
				    <SETG P-XADJ ,P-ADJ>
				    <SETG P-XADJN ,P-ADJN>
				    <SETG P-NAM <>>
				    <SETG P-ADJ <>>
				    <SETG P-ADJN <>>
				    <RTRUE>)
				   (T <TELL "It's too dark to see!" CR>)>)>
		      <SETG P-NAM <>>
		      <SETG P-ADJ <>>
		      <RFALSE>)
		     (<ZERO? .LEN> <SET GCHECK T> <AGAIN>)>
	       <SETG P-SLOCBITS .XBITS>
	       <SETG P-NAM <>>
	       <SETG P-ADJ <>>
	       <RTRUE>>>

<GLOBAL P-XNAM <>>
<GLOBAL P-XADJ <>>
<GLOBAL P-XADJN <>>

<ROUTINE WHICH-PRINT (TLEN LEN TBL "AUX" OBJ RLEN)
	 <SET RLEN .LEN>
	 <TELL "Which ">
         <COND (<OR ,P-OFLAG ,P-MERGED ,P-AND>
		<PRINTB <COND (,P-NAM ,P-NAM)
			      (,P-ADJ ,P-ADJN)
			      (ELSE ,W?ONE)>>)
	       (ELSE
		<THING-PRINT <EQUAL? .TBL ,P-PRSO>>)>
	 <TELL " do you mean, ">
	 <REPEAT ()
		 <SET TLEN <+ .TLEN 1>>
		 <SET OBJ <GET .TBL .TLEN>>
		 <TELL "the " D .OBJ>
		 <COND (<EQUAL? .LEN 2>
		        <COND (<NOT <EQUAL? .RLEN 2>> <TELL ",">)>
		        <TELL " or ">)
		       (<G? .LEN 2> <TELL ", ">)>
		 <COND (<L? <SET LEN <- .LEN 1>> 1>
		        <TELL "?" CR>
		        <RETURN>)>>>


<ROUTINE GLOBAL-CHECK (TBL "AUX" LEN RMG RMGL (CNT 0) OBJ OBITS FOO)
	<SET LEN <GET .TBL ,P-MATCHLEN>>
	<SET OBITS ,P-SLOCBITS>
	<COND (<SET RMG <GETPT ,HERE ,P?GLOBAL>>
	       <SET RMGL <- <PTSIZE .RMG> 1>>
	       <REPEAT ()
		       <COND (<THIS-IT? <SET OBJ <GETB .RMG .CNT>> .TBL>
			      <OBJ-FOUND .OBJ .TBL>)>
		       <COND (<IGRTR? CNT .RMGL> <RETURN>)>>)>
	<COND (<SET RMG <GETPT ,HERE ,P?PSEUDO>>
	       <SET RMGL <- </ <PTSIZE .RMG> 4> 1>>
	       <SET CNT 0>
	       <REPEAT ()
		       <COND (<EQUAL? ,P-NAM <GET .RMG <* .CNT 2>>>
			      <PUTP ,PSEUDO-OBJECT
				    ,P?ACTION
				    <GET .RMG <+ <* .CNT 2> 1>>>
			      <SET FOO
				   <BACK <GETPT ,PSEUDO-OBJECT ,P?ACTION> 5>>
			      <PUT .FOO 0 <GET ,P-NAM 0>>
			      <PUT .FOO 1 <GET ,P-NAM 1>>
			      <OBJ-FOUND ,PSEUDO-OBJECT .TBL>
			      <RETURN>)
		             (<IGRTR? CNT .RMGL> <RETURN>)>>)>
	<COND (<EQUAL? <GET .TBL ,P-MATCHLEN> .LEN>
	       <SETG P-SLOCBITS -1>
	       <SETG P-TABLE .TBL>
	       <DO-SL ,GLOBAL-OBJECTS 1 1>
	       <SETG P-SLOCBITS .OBITS>
	       <COND (<AND <ZERO? <GET .TBL ,P-MATCHLEN>>
			   <EQUAL? ,PRSA ,V?LOOK-INSIDE ,V?SEARCH ,V?EXAMINE>>
		      <DO-SL ,ROOMS 1 1>)>)>>

<ROUTINE DO-SL (OBJ BIT1 BIT2 "AUX" BTS)
	<COND (<BTST ,P-SLOCBITS <+ .BIT1 .BIT2>>
	       <SEARCH-LIST .OBJ ,P-TABLE ,P-SRCALL>)
	      (T
	       <COND (<BTST ,P-SLOCBITS .BIT1>
		      <SEARCH-LIST .OBJ ,P-TABLE ,P-SRCTOP>)
		     (<BTST ,P-SLOCBITS .BIT2>
		      <SEARCH-LIST .OBJ ,P-TABLE ,P-SRCBOT>)
		     (T <RTRUE>)>)>>

<CONSTANT P-SRCBOT 2>
<CONSTANT P-SRCTOP 0>
<CONSTANT P-SRCALL 1>

<ROUTINE SEARCH-LIST (OBJ TBL LVL "AUX" FLS NOBJ)
	<COND (<SET OBJ <FIRST? .OBJ>>
	       <REPEAT ()
		       <COND (<AND <NOT <EQUAL? .LVL ,P-SRCBOT>>
				   <GETPT .OBJ ,P?SYNONYM>
				   <THIS-IT? .OBJ .TBL>>
			      <OBJ-FOUND .OBJ .TBL>)>
		       <COND (<AND <OR <NOT <EQUAL? .LVL ,P-SRCTOP>>
				       <FSET? .OBJ ,SEARCHBIT>
				       <FSET? .OBJ ,SURFACEBIT>>
				   <SET NOBJ <FIRST? .OBJ>>
				   <OR <FSET? .OBJ ,OPENBIT>
				       <FSET? .OBJ ,TRANSBIT>>>
			      <SET FLS
				   <SEARCH-LIST .OBJ
						.TBL
						<COND (<FSET? .OBJ ,SURFACEBIT>
						       ,P-SRCALL)
						      (<FSET? .OBJ ,SEARCHBIT>
						       ,P-SRCALL)
						      (T ,P-SRCTOP)>>>)>
		       <COND (<SET OBJ <NEXT? .OBJ>>) (T <RETURN>)>>)>>

<ROUTINE OBJ-FOUND (OBJ TBL "AUX" PTR)
	<SET PTR <GET .TBL ,P-MATCHLEN>>
	<PUT .TBL <+ .PTR 1> .OBJ>
	<PUT .TBL ,P-MATCHLEN <+ .PTR 1>>>

<ROUTINE TAKE-CHECK ()
	<AND <ITAKE-CHECK ,P-PRSO <GETB ,P-SYNTAX ,P-SLOC1>>
	     <ITAKE-CHECK ,P-PRSI <GETB ,P-SYNTAX ,P-SLOC2>>>>

<ROUTINE ITAKE-CHECK (TBL IBITS "AUX" PTR OBJ TAKEN)
	 #DECL ((TBL) TABLE (IBITS PTR) FIX (OBJ) OBJECT
		(TAKEN) <OR FALSE FIX ATOM>)
	 <COND (<AND <SET PTR <GET .TBL ,P-MATCHLEN>>
		     <OR <BTST .IBITS ,SHAVE>
			 <BTST .IBITS ,STAKE>>>
		<REPEAT ()
			<COND (<L? <SET PTR <- .PTR 1>> 0> <RETURN>)
			      (T
			       <SET OBJ <GET .TBL <+ .PTR 1>>>
			       <COND (<EQUAL? .OBJ ,IT>
				      <COND (<NOT <ACCESSIBLE? ,P-IT-OBJECT>>
					     <TELL
"I don't see what you're referring to." CR>
					     <RFALSE>)
					    (T
					     <SET OBJ ,P-IT-OBJECT>)>)>
			       <COND (<AND <NOT <HELD? .OBJ>>
					   <NOT <EQUAL? .OBJ ,HANDS ,ME>>>
				      <SETG PRSO .OBJ>
				      <COND (<FSET? .OBJ ,TRYTAKEBIT>
					     <SET TAKEN T>)
					    (<NOT <EQUAL? ,WINNER ,ADVENTURER>>
					     <SET TAKEN <>>)
					    (<AND <BTST .IBITS ,STAKE>
						  <EQUAL? <ITAKE <>> T>>
					     <SET TAKEN <>>)
					    (T <SET TAKEN T>)>
				      <COND (<AND .TAKEN
						  <BTST .IBITS ,SHAVE>
						  <EQUAL? ,WINNER
							  ,ADVENTURER>>
					     <COND (<EQUAL? .OBJ
							    ,NOT-HERE-OBJECT>
						    <TELL
"You don't have that!" CR>
						    <RFALSE>)>
					     <TELL "You don't have the ">
					     <PRINTD .OBJ>
					     <TELL "." CR>
					     <RFALSE>)
					    (<AND <NOT .TAKEN>
						  <EQUAL? ,WINNER ,ADVENTURER>>
					     <TELL "(Taken)" CR>)>)>)>>)
	       (T)>>

<ROUTINE MANY-CHECK ("AUX" (LOSS <>) TMP)
	<COND (<AND <G? <GET ,P-PRSO ,P-MATCHLEN> 1>
		    <NOT <BTST <GETB ,P-SYNTAX ,P-SLOC1> ,SMANY>>>
	       <SET LOSS 1>)
	      (<AND <G? <GET ,P-PRSI ,P-MATCHLEN> 1>
		    <NOT <BTST <GETB ,P-SYNTAX ,P-SLOC2> ,SMANY>>>
	       <SET LOSS 2>)>
	<COND (.LOSS
	       <TELL "You can't use multiple ">
	       <COND (<EQUAL? .LOSS 2> <TELL "in">)>
	       <TELL "direct objects with \"">
	       <SET TMP <GET ,P-ITBL ,P-VERBN>>
	       <COND (<ZERO? .TMP> <TELL "tell">)
		     (<OR ,P-OFLAG ,P-MERGED>
		      <PRINTB <GET .TMP 0>>)
		     (T
		      <WORD-PRINT <GETB .TMP 2> <GETB .TMP 3>>)>
	       <TELL "\"." CR>
	       <RFALSE>)
	      (T)>>

<ROUTINE ZMEMQ (ITM TBL "OPTIONAL" (SIZE -1) "AUX" (CNT 1))
	<COND (<NOT .TBL> <RFALSE>)>
	<COND (<NOT <L? .SIZE 0>> <SET CNT 0>)
	      (ELSE <SET SIZE <GET .TBL 0>>)>
	<REPEAT ()
		<COND (<EQUAL? .ITM <GET .TBL .CNT>>
		       <RETURN <REST .TBL <* .CNT 2>>>)
		      (<IGRTR? CNT .SIZE> <RFALSE>)>>>

<ROUTINE ZMEMQB (ITM TBL SIZE "AUX" (CNT 0))
	<REPEAT ()
		<COND (<EQUAL? .ITM <GETB .TBL .CNT>>
		       <RTRUE>)
		      (<IGRTR? CNT .SIZE>
		       <RFALSE>)>>>

<GLOBAL ALWAYS-LIT <>>

<ROUTINE LIT? (RM "OPTIONAL" (RMBIT T) "AUX" OHERE (LIT <>))
	<COND (<AND ,ALWAYS-LIT <EQUAL? ,WINNER ,PLAYER>>
	       <RTRUE>)>
	<SETG P-GWIMBIT ,ONBIT>
	<SET OHERE ,HERE>
	<SETG HERE .RM>
	<COND (<AND .RMBIT
		    <FSET? .RM ,ONBIT>>
	       <SET LIT T>)
	      (T
	       <PUT ,P-MERGE ,P-MATCHLEN 0>
	       <SETG P-TABLE ,P-MERGE>
	       <SETG P-SLOCBITS -1>
	       <COND (<EQUAL? .OHERE .RM>
		      <DO-SL ,WINNER 1 1>
		      <COND (<AND <NOT <EQUAL? ,WINNER ,PLAYER>>
				  <IN? ,PLAYER .RM>>
			     <DO-SL ,PLAYER 1 1>)>)>
	       <DO-SL .RM 1 1>
	       <COND (<G? <GET ,P-TABLE ,P-MATCHLEN> 0> <SET LIT T>)>)>
	<SETG HERE .OHERE>
	<SETG P-GWIMBIT 0>
	.LIT>

<ROUTINE THIS-IT? (OBJ TBL "AUX" SYNS)
 <COND (<FSET? .OBJ ,INVISIBLE> <RFALSE>)
       (<AND ,P-NAM
	     <NOT <ZMEMQ ,P-NAM
			 <SET SYNS <GETPT .OBJ ,P?SYNONYM>>
			 <- </ <PTSIZE .SYNS> 2> 1>>>>
	<RFALSE>)
       (<AND ,P-ADJ
	     <OR <NOT <SET SYNS <GETPT .OBJ ,P?ADJECTIVE>>>
		 <NOT <ZMEMQB ,P-ADJ .SYNS <- <PTSIZE .SYNS> 1>>>>>
	<RFALSE>)
       (<AND <NOT <ZERO? ,P-GWIMBIT>> <NOT <FSET? .OBJ ,P-GWIMBIT>>>
	<RFALSE>)>
 <RTRUE>>

<ROUTINE ACCESSIBLE? (OBJ "AUX" (L <LOC .OBJ>)) ;"can player TOUCH object?"
	 ;"revised 5/2/84 by SEM and SWG"
	 <COND (<FSET? .OBJ ,INVISIBLE>
		<RFALSE>)
	       ;(<EQUAL? .OBJ ,PSEUDO-OBJECT>
		<COND (<EQUAL? ,LAST-PSEUDO-LOC ,HERE>
		       <RTRUE>)
		      (T
		       <RFALSE>)>)
	       (<NOT .L>
		<RFALSE>)
	       (<EQUAL? .L ,GLOBAL-OBJECTS>
		<RTRUE>)
	       (<AND <EQUAL? .L ,LOCAL-GLOBALS>
		     <GLOBAL-IN? .OBJ ,HERE>>
		<RTRUE>)
	       (<NOT <EQUAL? <META-LOC .OBJ> ,HERE <LOC ,WINNER>>>
		<RFALSE>)
	       (<EQUAL? .L ,WINNER ,HERE <LOC ,WINNER>>
		<RTRUE>)
	       (<AND <FSET? .L ,OPENBIT>
		     <ACCESSIBLE? .L>>
		<RTRUE>)
	       (T
		<RFALSE>)>>

<ROUTINE META-LOC (OBJ)
	 <REPEAT ()
		 <COND (<NOT .OBJ>
			<RFALSE>)
		       (<IN? .OBJ ,GLOBAL-OBJECTS>
			<RETURN ,GLOBAL-OBJECTS>)>
		 <COND (<IN? .OBJ ,ROOMS>
			<RETURN .OBJ>)
		       (T
			<SET OBJ <LOC .OBJ>>)>>>
