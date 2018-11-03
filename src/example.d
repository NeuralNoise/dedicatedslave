module _edev.dedicatedslave.src.example;
import std.stdio;

void main()
{
    auto a = new Abc();
    writeln("MemAddress of a: ", cast(void*)(a));
    writeln("MemAddress of a: ", a);
    doSth(a);
    
}

void doSth(Abc b)
{

    // Casting a reference to it will unleash the real memory address of the hidden, GC-managed instance
    writeln("MemAddress of b: ", cast(void*)(b));
    writeln("MemAddress of a: ", b);
}

class Abc
{
}