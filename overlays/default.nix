final: prev:
let
  ours = import ../pkgs { pkgs = prev; };
in
{
  wbrk = (prev.wbrk or { }) // ours.wbrk;
  hello-wbrk = ours.hello-wbrk;
}
