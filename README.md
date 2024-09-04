# ssd1306
 Простой пример кода работы с дисплеем ssd1306<br>
 для микроконтроллера attiny13 на gnu assembly.<br><br>
![plot](anoldlab.png)<br>
<br>cобрать исполняемый код<br>
<code>avr-gcc -no-pie -fno-stack-protector -fno-pic -Wall -mmcu=attiny13 -nostartfiles -nodefaultlibs  -o ssd1306.elf ssd1306.S</code>
<br>конвертировать бинарный код в шестнадцатиричный текстовый<br>
<code>avr-objcopy -O ihex ssd1306.elf ssd1306.hex</code>
<br>посмотреть размер кода<br>
<code>avr-size ssd1306.hex
   text	   data	    bss	    dec	    hex	filename
      0	    262	      0	    262	    106	ssd1306.hex</code>
<br>загрузить шестнадцатиричный формат в мк<br>
<code>avrdude -c usbasp -p attiny13 -B 10 -U flash:w:ssd1306.hex
</code>
