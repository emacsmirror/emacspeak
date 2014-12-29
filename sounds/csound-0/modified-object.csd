<CsoundSynthesizer>
<CsOptions>
-o modified-object.wav
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1   

gasig  init 0   
gidel  = 1		;delay time in seconds
                                                             
instr 1
	
ain  pluck .7, 440, 1000, 0, 1
     outs ain, ain

vincr gasig, ain	;send to global delay
endin

instr 2	

ifeedback = p4	

abuf2	delayr	gidel
adelL 	deltap	.4		;first tap (on left channel)
adelM 	deltap	1		;second tap (on middle channel)
	delayw	gasig + (adelL * ifeedback)

abuf3	delayr	gidel
kdel	line    1, p3, .01	;vary delay time
adelR 	deltap  .65 * kdel	;one pitch changing tap (on the right chn.)
	delayw	gasig + (adelR * ifeedback)
;make a mix of all deayed signals	
	outs	adelL + adelM, adelR + adelM

clear	gasig
endin

</CsInstruments>
<CsScore>
i 1 0 .25
  i 2 + .25  0

;i 2 0 3  0	;no feedback

e
</CsScore>
</CsoundSynthesizer>
