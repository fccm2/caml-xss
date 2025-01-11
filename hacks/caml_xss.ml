(* Xlib types *)
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

(* bindings elements to the Xlib *)
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

module type USER = sig
  type state
  type user_calls = {
    saver_init: x_elems -> state;
    saver_draw: x_elems -> state -> int;
    saver_reshape: x_elems -> state -> int -> int -> unit;
    saver_free: x_elems -> state -> unit;
  }
  val user_saver : user_calls
end

module MakeSaver (User : USER) = struct
  let _state = ref (None : User.state option)

  let init_callback x_elems =
    _state := Some (User.user_saver.saver_init x_elems);
  ;;

  let draw_callback x_elems =
    match !_state with None -> 1000000
    | Some _state -> User.user_saver.saver_draw x_elems _state;
  ;;

  let free_callback x_elems =
    match !_state with None -> ()
    | Some _state -> User.user_saver.saver_free x_elems _state;
  ;;

  let event_callback () =
    Printf.printf "e%!";
  ;;

  let reshape_callback x_elems w h =
    match !_state with None -> ()
    | Some _state -> User.user_saver.saver_reshape x_elems _state w h;
  ;;

  let install () =
    Callback.register "init-callback" init_callback;
    Callback.register "draw-callback" draw_callback;
    Callback.register "free-callback" free_callback;
    Callback.register "event-callback" event_callback;
    Callback.register "reshape-callback" reshape_callback;
  ;;
end

