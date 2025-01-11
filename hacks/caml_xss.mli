(** Interface to create savers for Xscreensaver in ocaml *)

(** Xlib types *)

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

module X : sig
  (** bindings elements to the Xlib *)

  val draw_point : x_elems -> int * int -> unit
  val draw_line : x_elems -> int * int * int * int -> unit
  val draw_rectangle : x_elems -> int * int * int * int -> unit
  val draw_arc : x_elems -> int * int * int * int * int * int -> unit
  val fill_rectangle : x_elems -> int * int * int * int -> unit
  val fill_arc : x_elems -> int * int * int * int * int * int -> unit
  val fill_polygon : x_elems -> (int * int) array -> unit
  val default_colormap : x_elems -> colormap
  val alloc_color : x_elems -> colormap -> int * int * int -> pixel
  val set_foreground : x_elems -> pixel -> unit
  val free_colors : x_elems -> colormap -> pixel -> unit
end

module type USER = sig
  type state
  type user_calls = {
    saver_init : x_elems -> state;
    saver_draw : x_elems -> state -> int;
    saver_reshape : x_elems -> state -> int -> int -> unit;
    saver_free: x_elems -> state -> unit;
  }
  val user_saver : user_calls
end

module MakeSaver : functor (User : USER) -> sig
  val install : unit -> unit
end

(** create a module with your saver with the type [USER],
    then use the functor like this:
    [module SomeSaver = MakeSaver(UserSaver)]
*)

