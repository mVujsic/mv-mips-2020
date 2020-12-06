;Author : Mateja Vujsic 617/2017
;Theme : Brick breaker - Prvi domaci zadatak 
;Subject : MIPS

sseg segment stack 'STACK'

     dw 64 dup(" ")

sseg ends


dseg segment 'DATA'

	;TODO
	BROJ_BLOKOVA DB 0Ch;

	VREME_PROTEKLO DB 0 ; vremenska promenljiva 
	
	LOPTICA_X DW 0h ; ; INIT
	LOPTICA_Y DW 70h ; 
	VELICINA_LOPTICE DW 03h ; velicina lopte 
	BRZINA_LOPTICE_PO_X DW 5h ; horizontalna brzine
	BRZINA_LOPTICE_PO_Y DW 2h ; vertikalna  brzine
	BOJA_LOPTICE DW 1h ; POCETNA BOJA LOPTICE
	
	BRZINA_PLATFORME DW 07h; brzina platforme

    BLOK_X DW 080h ; x pozicija  bloka INIT
    BLOK_Y DW 0BEh ; y pozicija  bloka INIT
	
	BLOK_X_1 DW 14h ; INIT  const za svaki red blokova
	BLOK_X_2 DW 5Fh
	BLOK_X_3 DW 0AAh
	BLOK_X_4 DW 0F5h
	
	BLOK_Y_1 DW 0Ah
	BLOK_Y_2 DW 19h
	BLOK_Y_3 DW 28h
	
    VELICINA_BLOKA_X DW 50h ; sirina
 	VELICINA_BLOKA_Y DW 0Ah ; visina 
	
	VELICINA_BLOKA_X_1 DW 37h
	VELICINA_BLOKA_Y_1 DW 0Ah
	
	;PARAMETERI ZA VELICNIU PROZORA I RANU KOLIZIJU 
    WINDOW_WIDTH DW 140h   
    WINDOW_HEIGHT DW 0C8h  
	WINDOW_BOUNDS DW 0     
    
	DESTRUKTOR_BLOKA_1_1 DW 1h
	DESTRUKTOR_BLOKA_1_2 DW 1h
	DESTRUKTOR_BLOKA_1_3 DW 1h
	DESTRUKTOR_BLOKA_1_4 DW 1h
	DESTRUKTOR_BLOKA_2_1 DW 1h
	DESTRUKTOR_BLOKA_2_2 DW 1h
	DESTRUKTOR_BLOKA_2_3 DW 1h
	DESTRUKTOR_BLOKA_2_4 DW 1h
	DESTRUKTOR_BLOKA_3_1 DW 1h
	DESTRUKTOR_BLOKA_3_2 DW 1h
	DESTRUKTOR_BLOKA_3_3 DW 1h
	DESTRUKTOR_BLOKA_3_4 DW 1h
	
	

dseg ends

cseg segment 'CODE'
    assume cs:cseg, ds:dseg, ss:sseg
    
	
	iscrtaj:
    CALL OBRISI_EKRAN
    CALL ISCRTAJ_PLATFORMU
	
	;Da program vidi var u DS
    MOV ax, dseg
    MOV ds, ax
	
	VREME_LOOP:
	
		MOV ah,2Ch ; sys time
		INT 21h    ; u DL su stotinke
		
		CMP dl,VREME_PROTEKLO  ; da li JE trenutno vreme jednako prethodnom (VREME_PROTEKLO)?
		JE VREME_LOOP    ; ako JE isto, proveri ponovo; inace ucrtaj loptu.
		
		MOV VREME_PROTEKLO,dl ; azuriraj vreme
		
		CALL OBRISI_EKRAN ; obrisi sadrzaj ekrana
		CALL POMJERI_LOPTU ; pomeri loptu
		CALL NACTAJ_JE  ; ucrtaj  JE
		CALL POMERI_PLATFORMU;
		CALL ISCRTAJ_PLATFORMU ;ucrtaj platformu  
		CALL NACRTAJ_1l_1
		CALL NACRTAJ_1l_2
		CALL NACRTAJ_1l_3
		CALL NACRTAJ_1l_4
		CALL NACRTAJ_2l_1
		CALL NACRTAJ_2l_2
		CALL NACRTAJ_2l_3
		CALL NACRTAJ_2_4
		CALL NACRTAJ_3l_1
		CALL NACRTAJ_3l_2
		CALL NACRTAJ_3l_3
		CALL NACRTAJ_3l_4
		JMP VREME_LOOP ; proveri vreme ponovo
		
		
	JMP kraj
	
	
	POMJERI_LOPTU PROC NEAR
		
		MOV ax,BRZINA_LOPTICE_PO_X    
		add LOPTICA_X,ax             
		
		MOV ax,WINDOW_BOUNDS
		CMP LOPTICA_X,ax                         
		jg desna
		CALL NEG_VELOCITY_X         ; LOPTICA_X < 0 + WINDOW_BOUNDS (sudar - leva ivica)
		MOV BOJA_LOPTICE, 2h
		
		desna:
		MOV ax,WINDOW_WIDTH
		sub ax,VELICINA_LOPTICE
		sub ax,WINDOW_BOUNDS
		CMP LOPTICA_X,ax	          ;LOPTICA_X > WINDOW_WIDTH - VELICINA_LOPTICE  - WINDOW_BOUNDS (sudar - desna ivica)
		jl gornja  
		CALL NEG_VELOCITY_X
		MOV BOJA_LOPTICE, 3h
		
		gornja:
		MOV ax,BRZINA_LOPTICE_PO_Y
		add LOPTICA_Y,ax             ; pomeri lopticu vertikalno
		
		MOV ax,WINDOW_BOUNDS
		CMP LOPTICA_Y,ax   		;LOPTICA_Y < 0 + WINDOW_BOUNDS (sudar - gornja ivica)
		jg ddd  
		CALL NEG_VELOCITY_Y                          
		MOV BOJA_LOPTICE, 4h
		
		ddd:
		
		MOV ax,WINDOW_HEIGHT	
		sub ax,VELICINA_LOPTICE
		sub ax, VELICINA_BLOKA_Y
		sub ax,WINDOW_BOUNDS
		CMP LOPTICA_Y,ax
		jge PROVERA_X	
		
		ret
		
		PROVERA_X:
			MOV ax, BLOK_X
			sub ax, VELICINA_LOPTICE
			CMP ax, LOPTICA_X
			JG KR
			MOV ax, BLOK_X
			ADD ax, VELICINA_BLOKA_X
			CMP AX, LOPTICA_X
			JL KR
			JMP NEG_VELOCITY_Y
			
		KR:
			JMP kraj
		
		NEG_VELOCITY_X:
			neg BRZINA_LOPTICE_PO_X   ;BRZINA_LOPTICE_PO_X = - BRZINA_LOPTICE_PO_X
			ret
			
		NEG_VELOCITY_Y:
			neg BRZINA_LOPTICE_PO_Y   ;BRZINA_LOPTICE_PO_Y = - BRZINA_LOPTICE_PO_Y
			ret
		
	POMJERI_LOPTU ENDP
	
	POMERI_PLATFORMU PROC NEAR
		
		MOV ah, 01h
		INT 16h
		jz EXIT_MV
		
		MOV ah, 00h
		INT 16h
		
		CMP ah, 4Bh
		JE MOVE_BLOCK_LEFT
		
		CMP ah, 4Dh
		JE MOVE_BLOCK_RIGHT
		JMP EXIT_MV
		
		MOVE_BLOCK_LEFT:
			MOV ax, BRZINA_PLATFORME
			sub BLOK_X, ax
			
			CMP BLOK_X, 0h
			jl FIX_BLOCK_LEFT
			JMP EXIT_MV
			
			FIX_BLOCK_LEFT:
				MOV BLOK_X,0h
				JMP EXIT_MV
		
		MOVE_BLOCK_RIGHT:
			MOV ax, BRZINA_PLATFORME
			add BLOK_X, ax
			MOV ax, WINDOW_WIDTH
			sub ax, WINDOW_BOUNDS
			sub ax, VELICINA_BLOKA_X
			CMP BLOK_X, ax
			jg FIX_BLOCK_RIGHT
			JMP EXIT_MV
			
			FIX_BLOCK_RIGHT:
				MOV BLOK_X, ax
				JMP EXIT_MV
		EXIT_MV:
			ret
			
	POMERI_PLATFORMU ENDP
	
	NACTAJ_JE PROC NEAR
		
		MOV cx,LOPTICA_X ; postavi inicijalnu kolonu (X)
		MOV dx,LOPTICA_Y ; postavi inicijalni red (Y)
		
		DRAW_BALL_HORIZONTAL:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
			CMP BOJA_LOPTICE, 1h
			jne lleva
			MOV al,0Bh ; izaberi belu boju
			
			lleva:
			CMP BOJA_LOPTICE, 2h
			jne ddesna		;ako nije udarila levi skoci na desni (ako udari u levi BOJA_LOPTICE=2h)
			MOV al, 06;    oboji lopticu u zuto ako JE udarila levi zid
			
			ddesna:
			CMP BOJA_LOPTICE, 3h
			jne ggornja
			MOV al, 03h  ;desni zid ekrana 
			
			ggornja:
			CMP BOJA_LOPTICE, 4h
			jne nastavak
			MOV al, 0Ah  ;lgreen
			
			nastavak:
			MOV bh,00h ; 
			INT 10h    ; izvrsi konfiguraciju
			
			inc cx     ;cx = cx + 1
			MOV ax,cx  
			sub ax,LOPTICA_X ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
			CMP ax,VELICINA_LOPTICE
			jng DRAW_BALL_HORIZONTAL
			
			MOV cx,LOPTICA_X ; vrati cx na inicijalnu kolonu
			inc dx        ; idemo u sledeci red
			
			MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
			sub ax,LOPTICA_Y
			CMP ax,VELICINA_LOPTICE
			jng DRAW_BALL_HORIZONTAL
		
		ret
	NACTAJ_JE ENDP

    ISCRTAJ_PLATFORMU PROC NEAR
		
		; U ovom kontekstu blok je platforma.
        MOV cx,BLOK_X 
        MOV dx,BLOK_Y 

        DRAW_BLOCK_HORIZONTAL:
            MOV ah,0Ch ; CONFIG
            MOV al,09h ; izaberi zelenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,VELICINA_BLOKA_X
            jng DRAW_BLOCK_HORIZONTAL

            MOV cx,BLOK_X ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_Y
            CMP ax,VELICINA_BLOKA_Y
            jng DRAW_BLOCK_HORIZONTAL

        ret
    ISCRTAJ_PLATFORMU ENDP
	
	NACRTAJ_1l_1 PROC NEAR
		MOV cx,BLOK_X_1 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_1; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_1_1, 0h;
		
		JE KRAJ_I_I
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_1
            jng DRAW_UP_HORIZONTAL_I_I

            MOV ax, BLOK_X_1
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_I_I

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_1
            jng DRAW_UP_HORIZONTAL_I_I

            MOV ax, BLOK_Y_1
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_I_I

            MOV DESTRUKTOR_BLOKA_1_1, 0
            ret		
		
		DRAW_UP_HORIZONTAL_I_I:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,04h ; izaberi crvenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_1 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_I_I

            MOV cx,BLOK_X_1 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_Y_1
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_I_I
			
			KRAJ_I_I:
			
		ret
	NACRTAJ_1l_1 ENDP
	
	NACRTAJ_1l_2 PROC NEAR
		MOV cx,BLOK_X_2 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_1; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_1_2, 0h;*
		
		JE KRAJ_I_II
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_2;*
            jng DRAW_UP_HORIZONTAL_I_II;*

            MOV ax, BLOK_X_2;*
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_I_II;*

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_1;*
            jng DRAW_UP_HORIZONTAL_I_II;*

            MOV ax, BLOK_Y_1;*
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_I_II;*

            MOV DESTRUKTOR_BLOKA_1_2, 0;*
            ret		
		
		DRAW_UP_HORIZONTAL_I_II:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,04h ; izaberi crvenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_2 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_I_II

            MOV cx,BLOK_X_2 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_Y_1
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_I_II
			
		KRAJ_I_II:
			
		ret
	NACRTAJ_1l_2 ENDP
	
	NACRTAJ_1l_3 PROC NEAR
		MOV cx,BLOK_X_3; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_1; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_1_3, 0h;*
		
		JE KRAJ_I_III
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_3;*
            jng DRAW_UP_HORIZONTAL_I_III;*
			
            MOV ax, BLOK_X_3;*
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_I_III;*

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_1;*
            jng DRAW_UP_HORIZONTAL_I_III;*

            MOV ax, BLOK_Y_1;*
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_I_III;*

            MOV DESTRUKTOR_BLOKA_1_3, 0;*
            ret
		
		DRAW_UP_HORIZONTAL_I_III:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,04h ; izaberi crvenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_3 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_I_III

            MOV cx,BLOK_X_3 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_Y_1
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_I_III
		KRAJ_I_III:
		ret
	NACRTAJ_1l_3 ENDP
	
	NACRTAJ_1l_4 PROC NEAR
		MOV cx,BLOK_X_4 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_1; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_1_4, 0h;*
		
		JE KRAJ_I_IV
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_4;*
            jng DRAW_UP_HORIZONTAL_I_IV;*

            MOV ax, BLOK_X_4;*
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_I_IV;*

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_1;*
            jng DRAW_UP_HORIZONTAL_I_IV;*

            MOV ax, BLOK_Y_1;*
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_I_IV;*

            MOV DESTRUKTOR_BLOKA_1_4, 0;*
            ret
		
		DRAW_UP_HORIZONTAL_I_IV:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,04h ; izaberi crvenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_4 
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_I_IV

            MOV cx,BLOK_X_4 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; 
            sub ax,BLOK_Y_1
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_I_IV
		KRAJ_I_IV:
		ret
	NACRTAJ_1l_4 ENDP
	
	NACRTAJ_2l_1 PROC NEAR
		MOV cx,BLOK_X_1 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_2; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_2_1, 0h;*
		
		JE KRAJ_II_I
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_1;*
            jng DRAW_UP_HORIZONTAL_II_I;*

            MOV ax, BLOK_X_1;*
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_II_I;*

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_2;*
            jng DRAW_UP_HORIZONTAL_II_I;*

            MOV ax, BLOK_Y_2;*
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_II_I;*

            MOV DESTRUKTOR_BLOKA_2_1, 0;*
            ret
		
		DRAW_UP_HORIZONTAL_II_I:
			MOV ah,0Ch ; CONFIG
            MOV al,0Eh ; zuta
            MOV bh,00h  
            INT 10h    

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_1 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_II_I

            MOV cx,BLOK_X_1 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_Y_2
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_II_I
		KRAJ_II_I:
		ret
	NACRTAJ_2l_1 ENDP
	
	NACRTAJ_2l_2 PROC NEAR
		MOV cx,BLOK_X_2 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_2; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_2_2, 0h;*
		
		JE KRAJ_II_II
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_2;*
            jng DRAW_UP_HORIZONTAL_II_II;*

            MOV ax, BLOK_X_2;*
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_II_II;*

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_2;*
            jng DRAW_UP_HORIZONTAL_II_II;*

            MOV ax, BLOK_Y_2;*
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_II_II;*

            MOV DESTRUKTOR_BLOKA_2_2, 0;*
            ret
		
		DRAW_UP_HORIZONTAL_II_II:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,0Eh ; izaberi zutu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_2 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_II_II

            MOV cx,BLOK_X_2 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_Y_2
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_II_II
		KRAJ_II_II:
		ret
	NACRTAJ_2l_2 ENDP
	
	NACRTAJ_2l_3 PROC NEAR
		MOV cx,BLOK_X_3; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_2; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_2_3, 0h;*
		
		JE KRAJ_II_III
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_3;*
            jng DRAW_UP_HORIZONTAL_II_III;*

            MOV ax, BLOK_X_3;*
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_II_III;*

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_2;*
            jng DRAW_UP_HORIZONTAL_II_III;*

            MOV ax, BLOK_Y_2;*
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_II_III;*

            MOV DESTRUKTOR_BLOKA_2_3, 0;*
            ret
		
		DRAW_UP_HORIZONTAL_II_III:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,0Eh ; izaberi zutu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_3 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_II_III

            MOV cx,BLOK_X_3 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_Y_2
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_II_III
		KRAJ_II_III:
		ret
	NACRTAJ_2l_3 ENDP
	
	NACRTAJ_2_4 PROC NEAR
		MOV cx,BLOK_X_4 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_2; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_2_4, 0h;*
		
		JE KRAJ_II_IV
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_4;*
            jng DRAW_UP_HORIZONTAL_II_IV;*

            MOV ax, BLOK_X_4;*
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_II_IV;*

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_2;*
            jng DRAW_UP_HORIZONTAL_iI_IV;*

            MOV ax, BLOK_Y_2;*
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_iI_IV;*

            MOV DESTRUKTOR_BLOKA_2_4, 0;*
            ret
		
		DRAW_UP_HORIZONTAL_II_IV:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,0Eh ; izaberi zutu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_4 
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_II_IV

            MOV cx,BLOK_X_4 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; 
            sub ax,BLOK_Y_2
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_II_IV
			
		KRAJ_II_IV:
		ret
	NACRTAJ_2_4 ENDP
	
	NACRTAJ_3l_1 PROC NEAR
		MOV cx,BLOK_X_1 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_3; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_3_1, 0h;
		
		JE KRAJ_III_I
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_1
            jng DRAW_UP_HORIZONTAL_III_I

            MOV ax, BLOK_X_1
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_III_I

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_3
            jng DRAW_UP_HORIZONTAL_III_I

            MOV ax, BLOK_Y_3
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_III_I

            MOV DESTRUKTOR_BLOKA_3_1, 0
            ret		
		
		DRAW_UP_HORIZONTAL_III_I:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,02h ; izaberi zelenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_1 
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_III_I

            MOV cx,BLOK_X_1 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; 
            sub ax,BLOK_Y_3
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_III_I
			
		KRAJ_III_I:
			
		ret
	NACRTAJ_3l_1 ENDP
	
	NACRTAJ_3l_2 PROC NEAR
		MOV cx,BLOK_X_2 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_3; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_3_2, 0h;*
		
		JE KRAJ_III_II
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_2;*
            jng DRAW_UP_HORIZONTAL_III_II;*

            MOV ax, BLOK_X_2;*
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_III_II;*

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_3;*
            jng DRAW_UP_HORIZONTAL_III_II;*

            MOV ax, BLOK_Y_3;*
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_III_II;*

            MOV DESTRUKTOR_BLOKA_3_2, 0;*
            ret		
		
		DRAW_UP_HORIZONTAL_III_II:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,02h ; izaberi zelenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_2 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_III_II

            MOV cx,BLOK_X_2 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_Y_3
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_III_II
			
		KRAJ_III_II:
			
		ret
	NACRTAJ_3l_2 ENDP
	
	NACRTAJ_3l_3 PROC NEAR
		MOV cx,BLOK_X_3; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_3; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_3_3, 0h;*
		
		JE KRAJ_III_III
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_3;*
            jng DRAW_UP_HORIZONTAL_III_III;*

            MOV ax, BLOK_X_3;*
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_III_III;*

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_3;*
            jng DRAW_UP_HORIZONTAL_III_III;*

            MOV ax, BLOK_Y_3;*
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_III_III;*

            MOV DESTRUKTOR_BLOKA_3_3, 0;*
            ret
		
		DRAW_UP_HORIZONTAL_III_III:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,02h ; izaberi zelenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_3 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_III_III

            MOV cx,BLOK_X_3 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_Y_3
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_III_III
		KRAJ_III_III:
		ret
	NACRTAJ_3l_3 ENDP
	
	NACRTAJ_3l_4 PROC NEAR
		MOV cx,BLOK_X_4 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_Y_3; postavi inicijalni red (Y)
		
		CMP DESTRUKTOR_BLOKA_3_4, 0h;*
		
		JE KRAJ_III_IV
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_X_4;*
            jng DRAW_UP_HORIZONTAL_III_IV;*

            MOV ax, BLOK_X_4;*
            add ax, VELICINA_BLOKA_X_1
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_III_IV;*

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_Y_3;*
            jng DRAW_UP_HORIZONTAL_III_IV;*

            MOV ax, BLOK_Y_3;*
            add ax, VELICINA_BLOKA_Y_1
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_III_IV;*

            MOV DESTRUKTOR_BLOKA_3_4, 0;*
            ret
		
		DRAW_UP_HORIZONTAL_III_IV:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,02h ; izaberi zelenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_X_4 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,VELICINA_BLOKA_X_1
            jng DRAW_UP_HORIZONTAL_III_IV

            MOV cx,BLOK_X_4 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_Y_3
            CMP ax,VELICINA_BLOKA_Y_1
            jng DRAW_UP_HORIZONTAL_III_IV
		KRAJ_III_IV:
		ret
	NACRTAJ_3l_4 ENDP


    OBRISI_EKRAN PROC NEAR
            MOV ah,00h ; postaviti konfiguraciju za video mod
            MOV al,13h ;
            INT 10h    ; izvrsi konfiguraciju
			MOV ah,0bh ; postavi konfiguraciju  za boju pozadine
            MOV bh,00h ;
            MOV bl,08h ; boja pozadine = siva
            INT 10h    ; izvrsi konfiguraciju

            ret
    OBRISI_EKRAN ENDP
	

kraj:   MOV ax, 4c00h 
		MOV ah, 0Bh
		MOV bh, 00h
		INT 10h; exit
        INT 21h
		
cseg     ends

end iscrtaj