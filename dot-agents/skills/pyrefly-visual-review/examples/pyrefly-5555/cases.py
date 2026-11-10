from typing import overload, reveal_type

def no_args() -> int: return 0
def unary(x: int) -> None: pass

@overload
def choose() -> str: ...
@overload
def choose(x: int, /) -> int: ...
def choose(*args: int) -> str | int: return args[0] if args else "empty"

def examples(xs: list[int], nonempty: tuple[int] | tuple[int, int], prefix: tuple[int, *tuple[int, ...]], suffix: tuple[*tuple[int, ...], int], too_many: tuple[int, int, *tuple[int, ...]], gradual: tuple[int, *tuple[object, ...]]) -> None:
    no_args(*nonempty)
    no_args(*xs)
    unary(1, *xs)
    no_args(*prefix)
    no_args(*suffix)
    unary(*too_many)
    unary(*suffix)
    no_args(*(1,))
    no_args(*())
    reveal_type(choose(*xs))
    reveal_type(choose(*prefix))
