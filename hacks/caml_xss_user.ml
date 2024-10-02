open Caml_xss

let () =
  let user_calls = {
    user_init = (fun () -> ());
    user_reshape = (fun w h -> ());
    user_draw = (fun xelms ->
      List.iter (X.draw_point xelms) [
        (20, 20); (22, 20); (24, 20)];
      X.draw_line xelms (20, 30, 60, 30);
      X.draw_rectangle xelms (20, 40, 60, 50);
      X.draw_arc xelms (40, 60, 20, 20, 0, 180*64);
    );
  } in
  Caml_xss.ref_user_calls user_calls;
;;
