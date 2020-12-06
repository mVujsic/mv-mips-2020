<h1 align=center>Микропроцесорски системи</h1>
<h3 align="center"> Aутор: Матеја Вујсић 617/2017</h3>

### Oпис: Први домаћи задатак - INT 10h x86
<div align="left" markdown="1">

- **Тражено**
- [x] Блокови,три реда, у траженој боји,  ✅
- [x] Платформа, у траженој боји ,✅
- [x] Kретање платформе на тастере ,✅
- [x] Физика и логика лоптице ,✅
- [x] Разбијање и уништавање ,✅
- [ ] Заустављање.... ❌  (Реално врати алоцирану меморију ОС)

- **Екстра функционалности**:
- [x] Промена боје лоптице на сваки ударац о зид.

</div>
<details>
<summary>Неопходно:</summary>
<ul>
<li>DosBox - x86 емулатор за ОС који нативно не покрећу DOS програме. https://www.dosbox.com/ </li>
<li>Masm/Tasm -DOS компајлери за assembly програме.</li>
<li>Link -програм за претварање .оbj у .еxe</li>
</ul>
</details>

<details><summary>Покретање:</summary>
<div markodown="1">
  
- **сместити .аsm фајл репоа у фолдер са изнад наведеним (2) (3).**
- **покренути DosBox** 
- **секвенцијално покренути следеће наредбе**
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
<div align="center">
<h1 align="center"><img src="https://github.com/mVujsic/mv-mips-2020/blob/master/snaps/gameplay.png" alt="Gameplay" /></h1>
</div>


