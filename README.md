# ssd1306
 Простой пример кода работы с дисплеем ssd1306<br>
 для микроконтроллера attiny13 на gnu assembly.<br><br>
![plot](anoldlab.png)<br>
<text>
собрать исполняемый код
</text>
<code>avr-gcc -no-pie -fno-stack-protector -fno-pic -Wall -mmcu=attiny13 -nostartfiles -nodefaultlibs  -o ssd1306.elf ssd1306.S</code>
конвертировать бинарный код в шестнадцатиричный текстовый
<code>avr-objcopy -O ihex ssd1306.elf ssd1306.hex</code>
посмотреть размер кода
<code>avr-size ssd1306.hex
   text	   data	    bss	    dec	    hex	filename
      0	    262	      0	    262	    106	ssd1306.hex</code>
загрузить шестнадцатиричный формат в мк
<code>avrdude -c usbasp -p attiny13 -B 10 -U flash:w:ssd1306.hex
</code>
