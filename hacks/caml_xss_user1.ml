open Caml_xss

module UserSaver = struct
  type state = unit
  type user_calls = {
    saver_init: x_elems -> state;
    saver_draw: x_elems -> state -> int;
    saver_reshape: x_elems -> state -> int -> int -> unit;
    saver_free: x_elems -> state -> unit;
  }
  let user_saver = {
    saver_init = (fun xelms -> ());
    saver_reshape = (fun xelms state w h -> ());
    saver_free = (fun xelms state -> ());
    saver_draw = (fun xelms state ->
      List.iter (X.draw_point xelms) [
        (20, 20); (22, 20); (24, 20)];
      X.draw_line xelms (20, 30, 60, 30);
      X.draw_rectangle xelms (20, 40, 60, 50);
      X.draw_arc xelms (40, 60, 20, 20, 0, 180*64);
      (200000)
    );
  }
end

module SomeSaver = MakeSaver(UserSaver) ;;
SomeSaver.install() ;;

