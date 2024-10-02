open Caml_xss

let dims = ref (0, 0)

let rand_color () =
  (Random.int 65536,
   Random.int 65536,
   Random.int 65536)

let () =
  let color = ref (rand_color ()) in
  let change_color () =
    match Random.int 20 with
    | 0 -> color := rand_color ()
    | 1 -> color := (0, 0, 0)
    | _ -> ()
  in

  let user_calls = {
    user_init = (fun xelms -> ());
    user_draw = (fun xelms ->
      change_color ();
      let colormap = X.default_colormap xelms in
      let px = X.alloc_color xelms colormap !color in
      X.set_foreground xelms px;
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
      X.free_colors xelms colormap px;
      (200000)
    );
    user_reshape = (fun w h ->
      dims := (w, h);
    );
  } in

  Caml_xss.ref_user_calls user_calls;
;;

