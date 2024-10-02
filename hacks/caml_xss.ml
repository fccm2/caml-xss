type display
type window
type gc
type colormap
type pixel

type x_elems = {
  display: display;
  window: window;
  gc: gc;
  w: int;
  h: int;
}

(* bindings elements *)
module X = struct
  external draw_point : x_elems -> int * int -> unit = "caml_xdrawpoint"
  external draw_rectangle : x_elems -> int * int * int * int -> unit = "caml_xdrawrectangle"
  external draw_line : x_elems -> int * int * int * int -> unit = "caml_xdrawline"
  external draw_arc : x_elems -> int * int * int * int * int * int -> unit = "caml_xdrawarc"
  external fill_rectangle : x_elems -> int * int * int * int -> unit = "caml_xfillrectangle"
  external fill_arc : x_elems -> int * int * int * int * int * int -> unit = "caml_xfillarc"
  external fill_polygon : x_elems -> (int * int) array -> unit = "caml_xfillpolygon"
  external default_colormap : x_elems -> colormap = "caml_xdefaultcolormap"
  external alloc_color : x_elems -> colormap -> int * int * int -> pixel = "caml_xalloccolor"
  external set_foreground : x_elems -> pixel -> unit = "caml_xsetforeground"
  external free_colors : x_elems -> colormap -> pixel -> unit = "caml_xfreecolors"
end


type user_calls = {
  user_draw: x_elems -> int;
  user_init: x_elems -> unit;
  user_reshape: int -> int -> unit;
}

let empty_calls = {
  user_draw = (fun x_elems -> (100000));
  user_init = (fun x_elems -> ());
  user_reshape = (fun x y -> ());
}

let default_calls = empty_calls
let usr_calls = ref empty_calls

let ref_user_calls _usr_calls =
  usr_calls := _usr_calls;
  ()
;;

let init_callback (x_elems) =
  print_endline "init_callback()";
  !usr_calls.user_init x_elems;
;;

let draw_callback (x_elems) =
  Printf.printf ".%!";
  !usr_calls.user_draw x_elems;
;;

let free_callback () =
  Printf.printf "free\n%!";
;;

let event_callback () =
  Printf.printf "e%!";
;;

let reshape_callback (w : int) (h : int) =
  Printf.printf "reshape: %d %d\n%!" w h;
  !usr_calls.user_reshape w h;
;;

let () =
  Callback.register "init-callback" init_callback;
  Callback.register "draw-callback" draw_callback;
  Callback.register "free-callback" free_callback;
  Callback.register "event-callback" event_callback;
  Callback.register "reshape-callback" reshape_callback;
;;
