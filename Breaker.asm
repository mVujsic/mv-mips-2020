;Author : Mateja Vujsic 617/2017
;Theme : Brick breaker - Prvi domaci zadatak 
;Subject : MIPS

sseg segment stack 'STACK'

     dw 64 dup(" ")

sseg ends


dseg segment 'DATA'

	VREME_PROTEKLO DB 0 ; vremenska promenljiva 
	LOPTICA_X DW 0h 
	LOPTICA_Y DW 70h ;
	VELICINA_LOPTICE DW 03h ; velicina lopte 
	BRZINA_LOPTICE_PO_X DW 5h ; horizontalna brzine
	BRZINA_LOPTICE_PO_Y DW 2h ; vertikalna  brzine
	BOJA_LOPTICE DW 1h 

	;******************************blokovi
	BLOK_KOLONA1 DW 10h
	BLOK_KOLONA2 DW 5Fh
	BLOK_KOLONA3 DW 0A9h
	BLOK_KOLONA4 DW 0F8h
	
	BLOK_RED1 DW 0Ah
	BLOK_RED2 DW 1Fh
	BLOK_RED3 DW 36h
	
	SIRINA_BLOKOVA DW 37h
	VISINA_BLOKOVA DW 0Ah
	
	SUDAR_BLOK11 DW 1h
	SUDAR_BLOK12 DW 1h
	SUDAR_BLOK13 DW 1h
	SUDAR_BLOK14 DW 1h
	SUDAR_BLOK21 DW 1h
	SUDAR_BLOK22 DW 1h
	SUDAR_BLOK23 DW 1h
	SUDAR_BLOK24 DW 1h
	SUDAR_BLOK31 DW 1h
	SUDAR_BLOK32 DW 1h
	SUDAR_BLOK33 DW 1h
	SUDAR_BLOK34 DW 1h
	
	
	;*****************************platforma 
	PLATFORMA_X DW 080h 
    PLATFORMA_y DW 0BDh 
	SIRINA_PLATFORME DW 55h 
 	VISINA_PLATFORME DW 0Ah 
	
	;PARAMETERI ZA VELICNIU PROZORA I RANU KOLIZIJU 
    WINDOW_WIDTH DW 140h   ;320
    WINDOW_HEIGHT DW 0C8h  ;200
	WINDOW_BOUNDS DW 0     
	
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
		CALL POMERI_LOPTU ; pomeri loptu
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
	
	
	POMERI_LOPTU PROC NEAR
		
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
		jg dalje  
		CALL NEG_VELOCITY_Y                          
		MOV BOJA_LOPTICE, 4h
		
		dalje:
		
		MOV ax,WINDOW_HEIGHT	
		sub ax,VELICINA_LOPTICE
		sub ax, VISINA_PLATFORME 
		sub ax,WINDOW_BOUNDS
		CMP LOPTICA_Y,ax
		jge PROVERA_X	
		
		ret
		
		PROVERA_X:
			MOV ax, PLATFORMA_X
			sub ax, VELICINA_LOPTICE
			CMP ax, LOPTICA_X
			JG KR
			MOV ax, PLATFORMA_X
			ADD ax, SIRINA_PLATFORME
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
		
	POMERI_LOPTU ENDP
	
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
			dec PLATFORMA_X
			dec PLATFORMA_X
			dec PLATFORMA_X
			dec PLATFORMA_X
			dec PLATFORMA_X
			
			CMP PLATFORMA_X, 0h
			jl FIX_BLOCK_LEFT
			JMP EXIT_MV
			
			FIX_BLOCK_LEFT:
				MOV PLATFORMA_X,0h
				JMP EXIT_MV
		
		MOVE_BLOCK_RIGHT:
			inc PLATFORMA_X
			inc PLATFORMA_X
			inc PLATFORMA_X
			inc PLATFORMA_X
			inc PLATFORMA_X
			
			MOV ax, WINDOW_WIDTH
			sub ax, WINDOW_BOUNDS
			sub ax, SIRINA_PLATFORME
			CMP PLATFORMA_X, ax
			jg FIX_BLOCK_RIGHT
			JMP EXIT_MV
			
			FIX_BLOCK_RIGHT:
				MOV PLATFORMA_X, ax
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
        MOV cx,PLATFORMA_X 
        MOV dx,PLATFORMA_y 

        DRAW_BLOCK_HORIZONTAL:
            MOV ah,0Ch ; CONFIG
            MOV al,09h ; izaberi zelenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,PLATFORMA_X ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,SIRINA_PLATFORME
            jng DRAW_BLOCK_HORIZONTAL

            MOV cx,PLATFORMA_X ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,PLATFORMA_y
            CMP ax,VISINA_PLATFORME 
            jng DRAW_BLOCK_HORIZONTAL

        ret
    ISCRTAJ_PLATFORMU ENDP
	
	NACRTAJ_1l_1 PROC NEAR
		MOV cx,BLOK_KOLONA1 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED1; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK11, 0h;
		
		JE KRAJ_I_I
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA1
            jng DRAW_UP_HORIZONTAL_I_I

            MOV ax, BLOK_KOLONA1
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_I_I

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED1
            jng DRAW_UP_HORIZONTAL_I_I

            MOV ax, BLOK_RED1
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_I_I

            MOV SUDAR_BLOK11, 0
            ret		
		
		DRAW_UP_HORIZONTAL_I_I:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,04h ; izaberi crvenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA1 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_I_I

            MOV cx,BLOK_KOLONA1 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_RED1
            CMP ax,VISINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_I_I
			
			KRAJ_I_I:
			
		ret
	NACRTAJ_1l_1 ENDP
	
	NACRTAJ_1l_2 PROC NEAR
		MOV cx,BLOK_KOLONA2 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED1; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK12, 0h; 
		
		JE KRAJ_I_II
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA2; 
            jng DRAW_UP_HORIZONTAL_I_II; 

            MOV ax, BLOK_KOLONA2; 
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_I_II; 

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED1; 
            jng DRAW_UP_HORIZONTAL_I_II; 

            MOV ax, BLOK_RED1; 
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_I_II; 

            MOV SUDAR_BLOK12, 0; 
            ret		
		
		DRAW_UP_HORIZONTAL_I_II:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,04h ; izaberi crvenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA2 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_I_II

            MOV cx,BLOK_KOLONA2 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_RED1
            CMP ax,VISINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_I_II
			
		KRAJ_I_II:
			
		ret
	NACRTAJ_1l_2 ENDP
	
	NACRTAJ_1l_3 PROC NEAR
		MOV cx,BLOK_KOLONA3; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED1; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK13, 0h; 
		
		JE KRAJ_I_III
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA3; 
            jng DRAW_UP_HORIZONTAL_I_III; 
			
            MOV ax, BLOK_KOLONA3; 
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_I_III; 

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED1; 
            jng DRAW_UP_HORIZONTAL_I_III; 

            MOV ax, BLOK_RED1; 
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_I_III; 

            MOV SUDAR_BLOK13, 0; 
            ret
		
		DRAW_UP_HORIZONTAL_I_III:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,04h ; izaberi crvenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA3 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_I_III

            MOV cx,BLOK_KOLONA3 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_RED1
            CMP ax,VISINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_I_III
		KRAJ_I_III:
		ret
	NACRTAJ_1l_3 ENDP
	
	NACRTAJ_1l_4 PROC NEAR
		MOV cx,BLOK_KOLONA4 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED1; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK14, 0h; 
		
		JE KRAJ_I_IV
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA4; 
            jng DRAW_UP_HORIZONTAL_I_IV; 

            MOV ax, BLOK_KOLONA4; 
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_I_IV; 

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED1; 
            jng DRAW_UP_HORIZONTAL_I_IV; 

            MOV ax, BLOK_RED1; 
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_I_IV; 

            MOV SUDAR_BLOK14, 0; 
            ret
		
		DRAW_UP_HORIZONTAL_I_IV:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,04h ; izaberi crvenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA4 
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_I_IV

            MOV cx,BLOK_KOLONA4 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; 
            sub ax,BLOK_RED1
            CMP ax,VISINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_I_IV
		KRAJ_I_IV:
		ret
	NACRTAJ_1l_4 ENDP
	
	NACRTAJ_2l_1 PROC NEAR
		MOV cx,BLOK_KOLONA1 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED2; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK21, 0h; 
		
		JE KRAJ_II_I
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA1; 
            jng DRAW_UP_HORIZONTAL_II_I; 

            MOV ax, BLOK_KOLONA1; 
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_II_I; 

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED2; 
            jng DRAW_UP_HORIZONTAL_II_I; 

            MOV ax, BLOK_RED2; 
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_II_I; 

            MOV SUDAR_BLOK21, 0; 
            ret
		
		DRAW_UP_HORIZONTAL_II_I:
			MOV ah,0Ch ; CONFIG
            MOV al,0Eh ; zuta
            MOV bh,00h  
            INT 10h    

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA1 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_II_I

            MOV cx,BLOK_KOLONA1 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_RED2
            CMP ax,VISINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_II_I
		KRAJ_II_I:
		ret
	NACRTAJ_2l_1 ENDP
	
	NACRTAJ_2l_2 PROC NEAR
		MOV cx,BLOK_KOLONA2 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED2; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK22, 0h; 
		
		JE KRAJ_II_II
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA2; 
            jng DRAW_UP_HORIZONTAL_II_II; 

            MOV ax, BLOK_KOLONA2; 
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_II_II; 

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED2; 
            jng DRAW_UP_HORIZONTAL_II_II; 

            MOV ax, BLOK_RED2; 
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_II_II; 

            MOV SUDAR_BLOK22, 0; 
            ret
		
		DRAW_UP_HORIZONTAL_II_II:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,0Eh ; izaberi zutu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA2 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_II_II

            MOV cx,BLOK_KOLONA2 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_RED2
            CMP ax,VISINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_II_II
		KRAJ_II_II:
		ret
	NACRTAJ_2l_2 ENDP
	
	NACRTAJ_2l_3 PROC NEAR
		MOV cx,BLOK_KOLONA3; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED2; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK23, 0h; 
		
		JE KRAJ_II_III
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA3; 
            jng DRAW_UP_HORIZONTAL_II_III; 

            MOV ax, BLOK_KOLONA3; 
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_II_III; 

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED2; 
            jng DRAW_UP_HORIZONTAL_II_III; 

            MOV ax, BLOK_RED2; 
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_II_III; 

            MOV SUDAR_BLOK23, 0; 
            ret
		
		DRAW_UP_HORIZONTAL_II_III:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,0Eh ; izaberi zutu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA3 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_II_III

            MOV cx,BLOK_KOLONA3 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_RED2
            CMP ax,VISINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_II_III
		KRAJ_II_III:
		ret
	NACRTAJ_2l_3 ENDP
	
	NACRTAJ_2_4 PROC NEAR
		MOV cx,BLOK_KOLONA4 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED2; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK24, 0h; 
		
		JE KRAJ_II_IV
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA4; 
            jng DRAW_UP_HORIZONTAL_II_IV; 

            MOV ax, BLOK_KOLONA4; 
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_II_IV; 

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED2; 
            jng DRAW_UP_HORIZONTAL_iI_IV; 

            MOV ax, BLOK_RED2; 
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_iI_IV; 

            MOV SUDAR_BLOK24, 0; 
            ret
		
		DRAW_UP_HORIZONTAL_II_IV:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,0Eh ; izaberi zutu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA4 
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_II_IV

            MOV cx,BLOK_KOLONA4 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; 
            sub ax,BLOK_RED2
            CMP ax,VISINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_II_IV
			
		KRAJ_II_IV:
		ret
	NACRTAJ_2_4 ENDP
	
	NACRTAJ_3l_1 PROC NEAR
		MOV cx,BLOK_KOLONA1 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED3; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK31, 0h;
		
		JE KRAJ_III_I
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA1
            jng DRAW_UP_HORIZONTAL_III_I

            MOV ax, BLOK_KOLONA1
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_III_I

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED3
            jng DRAW_UP_HORIZONTAL_III_I

            MOV ax, BLOK_RED3
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_III_I

            MOV SUDAR_BLOK31, 0
            ret		
		
		DRAW_UP_HORIZONTAL_III_I:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,02h ; izaberi zelenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA1 
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_III_I

            MOV cx,BLOK_KOLONA1 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; 
            sub ax,BLOK_RED3
            CMP ax,VISINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_III_I
			
		KRAJ_III_I:
			
		ret
	NACRTAJ_3l_1 ENDP
	
	NACRTAJ_3l_2 PROC NEAR
		MOV cx,BLOK_KOLONA2 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED3; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK32, 0h; 
		
		JE KRAJ_III_II
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA2; 
            jng DRAW_UP_HORIZONTAL_III_II; 

            MOV ax, BLOK_KOLONA2; 
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_III_II; 

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED3; 
            jng DRAW_UP_HORIZONTAL_III_II; 

            MOV ax, BLOK_RED3; 
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_III_II; 

            MOV SUDAR_BLOK32, 0; 
            ret		
		
		DRAW_UP_HORIZONTAL_III_II:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,02h ; izaberi zelenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA2 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_III_II

            MOV cx,BLOK_KOLONA2 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_RED3
            CMP ax,VISINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_III_II
			
		KRAJ_III_II:
			
		ret
	NACRTAJ_3l_2 ENDP
	
	NACRTAJ_3l_3 PROC NEAR
		MOV cx,BLOK_KOLONA3; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED3; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK33, 0h; 
		
		JE KRAJ_III_III
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA3; 
            jng DRAW_UP_HORIZONTAL_III_III; 

            MOV ax, BLOK_KOLONA3; 
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_III_III; 

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED3; 
            jng DRAW_UP_HORIZONTAL_III_III; 

            MOV ax, BLOK_RED3; 
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_III_III; 

            MOV SUDAR_BLOK33, 0; 
            ret
		
		DRAW_UP_HORIZONTAL_III_III:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,02h ; izaberi zelenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA3 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_III_III

            MOV cx,BLOK_KOLONA3 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_RED3
            CMP ax,VISINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_III_III
		KRAJ_III_III:
		ret
	NACRTAJ_3l_3 ENDP
	
	NACRTAJ_3l_4 PROC NEAR
		MOV cx,BLOK_KOLONA4 ; postavi inicijalnu kolonu (X)
        MOV dx,BLOK_RED3; postavi inicijalni red (Y)
		
		CMP SUDAR_BLOK34, 0h; 
		
		JE KRAJ_III_IV
			MOV ax, LOPTICA_X
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_KOLONA4; 
            jng DRAW_UP_HORIZONTAL_III_IV; 

            MOV ax, BLOK_KOLONA4; 
            add ax, SIRINA_BLOKOVA
            CMP LOPTICA_X, ax
            jnl DRAW_UP_HORIZONTAL_III_IV; 

            MOV ax, LOPTICA_Y
            add ax, VELICINA_LOPTICE
            CMP ax, BLOK_RED3; 
            jng DRAW_UP_HORIZONTAL_III_IV; 

            MOV ax, BLOK_RED3; 
            add ax, VISINA_BLOKOVA
            CMP LOPTICA_Y, ax
            jnl DRAW_UP_HORIZONTAL_III_IV; 

            MOV SUDAR_BLOK34, 0; 
            ret
		
		DRAW_UP_HORIZONTAL_III_IV:
			MOV ah,0Ch ; podesi konfiguraciju za ispis piksela
            MOV al,02h ; izaberi zelenu boju
            MOV bh,00h ; 
            INT 10h    ; izvrsi konfiguraciju

            inc cx     ;cx = cx + 1
            MOV ax,cx
            sub ax,BLOK_KOLONA4 ;cx - LOPTICA_X > VELICINA_LOPTICE (ako jeste, iscrtali smo za taj red sve kolone; inace nastavljamo dalje)
            CMP ax,SIRINA_BLOKOVA
            jng DRAW_UP_HORIZONTAL_III_IV

            MOV cx,BLOK_KOLONA4 ; vrati cx na inicijalnu kolonu
            inc dx        ; idemo u sledeci red

            MOV ax,dx    ; dx - LOPTICA_Y > VELICINA_LOPTICE (ako jeste, iscrtali smo sve redove piksela; inace nastavljamo dalje)
            sub ax,BLOK_RED3
            CMP ax,VISINA_BLOKOVA
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