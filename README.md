<h1 align=center>Микропроцесорски системи</h1>

### Aутор: Матеја Вујсић 617/2017
### Oпис: Први домаћи задатак
- [x] Блокови,три реда, у траженој боји,
- [ ] Платформа, у траженој боји,
- [ ] Kретање платформе на тастере,
- [x] Физика и логика лоптице,
- [x] Разбијање и уништавање,
- [ ] Заустављање.
<details><summary><h3 align="left">Потребно инсталирати следеће:</h3></summary>
<ul>
<li>DosBox - x86 емулатор за ОС који нативно не покрећу DOS програме. https://www.dosbox.com/ </li>
<li>Masm/Tasm -DOS компајлери за assembly програме.</li>
<li>Link -програм за претварање .оbj у .еxe</li>
</ul>
</details>

<details><summary><h3>Покретање програма:</h3></summary>
<div markodown="1">
  
1. **сместити .аsm фајл репоа у фолдер са изнад наведеним (2) (3).**
2. **покренути DosBox** 
3. **секвенцијално покренути следеће наредбе**
``` bat
mount c: <путања_до_фолдера>
c:
masm /a <име>.ASM
link <име>.OBJ
<ime>.EXE
```
</div>
</details>

### Изглед програма