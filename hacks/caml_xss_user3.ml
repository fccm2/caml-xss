open Caml_xss

module User1 = struct
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

module SomeSaver = MakeSaver(UserSaver)
end

module User2 = struct
let dims = ref (100, 60)

let rand_color () =
  (Random.int 65536,
   Random.int 65536,
   Random.int 65536)

let color = ref (rand_color ())

let change_color () =
  match Random.int 20 with
  | 0 -> color := rand_color (); true
  | 1 -> color := (0, 0, 0); true
  | _ -> (); false

module UserSaver = struct
  type state = {
    colormap: Caml_xss.colormap;
    mutable color: pixel;
  }
  type user_calls = {
    saver_init: x_elems -> state;
    saver_draw: x_elems -> state -> int;
    saver_reshape: x_elems -> state -> int -> int -> unit;
    saver_free: x_elems -> state -> unit;
  }
  let user_saver = {
    saver_init = (fun xelms ->
      let colormap = X.default_colormap xelms in
      let color = X.alloc_color xelms colormap !color in
      X.set_foreground xelms color;
      { colormap;
        color;
      }
    );
    saver_reshape = (fun xelms state w h ->
      dims := (w, h);
    );
    saver_free = (fun xelms state ->
      X.free_colors xelms state.colormap state.color;
    );
    saver_draw = (fun xelms state ->
      if change_color ()
      then begin
        X.free_colors xelms state.colormap state.color;
        state.color <- X.alloc_color xelms state.colormap !color;
        X.set_foreground xelms state.color;
      end;
      let w, h = !dims in
      for i = 0 to pred 24 do
        let x = Random.int w in
        let y = Random.int h in
        X.draw_point xelms (x, y);
      done;
      for i = 0 to pred 12 do
        let x1 = Random.int (w - 30) in
        let x2 = x1 + Random.int 60 in
        let y = Random.int h in
        X.draw_line xelms (x1, y, x2, y);
      done;
      (200000)
    );
  }
end

module SomeSaver = MakeSaver(UserSaver)
end ;;

if false then
  User1.SomeSaver.install()
else
  User2.SomeSaver.install()
;;

