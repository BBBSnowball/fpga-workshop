Test 1
======

Anleitung
---------

1. Quartus starten
2. Programmer starten (Tools -> Programmer)
3. USB Blaster anschließen an PC und Board, Board mit Strom versorgen, USB Blaster in Programmer auswählen (unter Hardware Setup)
4. Auto Detect; Ihr müsst dann die richtige Variante auswählen - nämlich EP4CE6, weil die Hardware-ID ist leider nicht eindeutig.
5. Da steht als Datei noch "<none>". Darauf Rechtsklick und Change File. Da wählt ihr die `00_Testdesign.sof` aus.
6. Haken bei Program/Configure setzen.
7. Start klicken.
8. Falls es nicht auf Anhieb funktioniert, noch mal auf Start klicken.

Troubleshooting
---------------

- Unter Windows: Ist der Treiber installiert?
- Unter Linux: Passen die Rechte von dem USB-Gerät?
- Unter Linux: SElinux/AppArmor/etc kann eventuell stören.


Test 2
======

Anleitung
---------

1. ModelSim Altera Edition starten.
2. Projekt `testproject.mpf` öffnen.
3. In der Tcl-Konsole führt ihr folgenden Befehl aus: `do msim_run.do`

Troubleshooting
---------------

- Unter Linux: Eventuell müsst ihr ggf noch 32-bit Bibliotheken installieren - ggf. in passender Version. Ich habe mein Hilfsskript mal nach ../modelsim-patch gelegt. Eventuell hilft das jemandem weiter.


Test 3
======

Anleitung
---------

1. Quartus starten
2. NIOS II Tools starten (Tools -> NIOS II Software Build Tools for Eclipse)

Troubleshooting
---------------

- Die Executable dazu ist: /path/to/quartus/nios2eds/bin/eclipse-nios2
- Logs sind in: ~/.altera.sbt4e/configuration/*.log
- Bei mir fehlte (allerdings bei Quartus 13) libgtk-x11-2.0.so.0.
  Das ist gtk2.i686 bei Fedora 23. Die Libary, die das braucht, ist diese hier:
  `~/.altera.sbt4e/configuration/org.eclipse.osgi/bundles/271/1/.cp/libswt-pi-gtk-3740.so`

