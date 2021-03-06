
(* returns updated list of blocks *)
let block_helper1 
  (instrs: arm_program)
  (blocks: block list)
  (current_blk: block option)
  : (block list * block) = 
  match instrs with 
  | [] -> 
    begin
      match current_blk with
      | Some current_blk -> (blocks, current_blk)
      | None -> failwith "#20: current_blk doesn't exist"
    end
  | i::is ->
    match i with
    | Label label -> (*create new block*)
      let blk_id = fresh_blk () in
      let line_id = fresh_line () in
      (* update current block *)
      let label_instruction = (line_id, false, i) in
      let new_blk = {
        id = blk_id;
        label = label;
        instrs = [label_instruction];
        instrs_in = []; 
        instrs_out = []
      } in
      begin
        match current_blk with
        | Some current_blk  ->           (* Update current block and create new block *)
          let last_instr = last current_blk.instrs in  (* add label instruction to current_blk.instrs_out *)
           new_blk.instrs_in      <- (last_instr, current_blk.id, current_blk.label) :: []; 
           current_blk.instrs_out <- List.append current_blk.instrs_out [(label_instruction, blk_id, label)];
           (List.append blocks [current_blk], new_blk)     (* return list of blocks and new (current) block *)
        | None -> ([], new_blk)           (* No block exists, create new block *) (*thisfunction [new_block] new_blk *)
      end
    | PseudoInstr pseudo ->
      let line_id = fresh_line () in
      let p_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk -> 
          current_blk.instrs <- List.append current_blk.instrs [p_instruction];
          let pseudo_instr = (p_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [pseudo_instr];
            (blocks, current_blk)
        | None -> failwith "#6: Pseudo instrction block current block doesn't exist." 
            (* only temporary as isntructions can start with a pseudoinstr *)
      end 
    | B (cond, b_label) -> (* branch *)
      let line_id = fresh_line () in
      let b_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk ->
          current_blk.instrs <- List.append current_blk.instrs [b_instruction];
          let branch_instr = (b_instruction, current_blk.id, current_blk.label) in 
            current_blk.instrs_out <- List.append current_blk.instrs_out [branch_instr];
            if current_blk.label == b_label then 
              begin
                current_blk.instrs_in <- List.append current_blk.instrs_in [branch_instr];
                (blocks, current_blk) 
              end
            else 
              let rec helper bs label = (* find block w/ matching label *)
                match bs, label with 
                | [], _ -> failwith "#5: Block with label wasn't found"
                | b::bs, label ->
                  if b.label == label then
                    begin
                      b.instrs_in <- List.append b.instrs_in [branch_instr];
                      List.append [b] bs 
                    end
                  else List.append [b] (helper bs label)
              in (helper blocks b_label, current_blk) 
        | None -> failwith "#4: Branch - current block doesn't exist"
      end
    | BL (cond, b_label) -> (* branch *)
      let line_id = fresh_line () in
      let bl_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk ->
          current_blk.instrs <- List.append current_blk.instrs [bl_instruction];
          let branch_instr = (bl_instruction, current_blk.id, current_blk.label) in 
            current_blk.instrs_out <- List.append current_blk.instrs_out [branch_instr];
            if current_blk.label == b_label then 
              begin
                current_blk.instrs_in <- List.append current_blk.instrs_in [branch_instr];
                (blocks, current_blk) 
              end
            else 
              let rec helper bs label = (* find block w/ matching label *)
                match bs, label with 
                | [], _ -> failwith "#5: Block with label wasn't found"
                | b::bs, label ->
                  if b.label == label then
                    begin
                      b.instrs_in <- List.append b.instrs_in [branch_instr];
                      List.append [b] bs 
                    end
                  else List.append [b] (helper bs label)
              in (helper blocks b_label, current_blk) 
        | None -> failwith "#4: Branch - current block doesn't exist"
      end 
    | LDMFD reg_list ->
      let line_id = fresh_line () in
      let ldmfd_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk -> 
          current_blk.instrs <- List.append current_blk.instrs [ldmfd_instruction];
          let ldmfd_instr = (ldmfd_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [ldmfd_instr];
            (blocks, current_blk)
        | None -> failwith "#17: ldmfd instrction block current block doesn't exist." 
      end
    | STMFD reg_list ->
      let line_id = fresh_line () in
      let stmfd_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk -> 
          current_blk.instrs <- List.append current_blk.instrs [stmfd_instruction];
          let stmfd_instr = (stmfd_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [stmfd_instr];
            (blocks, current_blk)
        | None -> failwith "#17: ldmfd instrction block current block doesn't exist." 
      end
    | LDR (cond, wordtype, rd, address_type) -> 
      let line_id = fresh_line () in
      let ldr_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk ->
          current_blk.instrs <- List.append current_blk.instrs [ldr_instruction];
          let ldr_instr = (ldr_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [ldr_instr];
            (blocks, current_blk)
        | None -> failwith "#15: LDR instrction block current block doesn't exist." 
      end
    | STR (cond, wordtype, rd, address_type) -> 
      let line_id = fresh_line () in
      let str_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk ->
          current_blk.instrs <- List.append current_blk.instrs [str_instruction];
          let str_instr = (str_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [str_instr];
            (blocks, current_blk)
        | None -> failwith "#16: STR instrction block current block doesn't exist." 
      end
    | MOV (cond, suffix, rd, operand_type) -> (* not fully implemented *)
      let line_id = fresh_line () in
      let mov_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk -> 
          current_blk.instrs <- List.append current_blk.instrs [mov_instruction];
          let mov_instr = (mov_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [mov_instr];
            (blocks, current_blk)
        | None -> failwith "#14: MOV instrction block current block doesn't exist." 
      end
    | CMP (cond, rd, operand_type) -> (* not fully implemented *)
      let line_id = fresh_line () in
      let cmp_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk -> 
          current_blk.instrs <- List.append current_blk.instrs [cmp_instruction];
          let cmp_instr = (cmp_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [cmp_instr];
            (blocks, current_blk)
        | None -> failwith "#13: CMP instrction block current block doesn't exist." 
      end
    | MUL (cond, suffix, rd, rn1, rn2) ->
      let line_id = fresh_line () in
      let mul_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk -> 
          current_blk.instrs <- List.append current_blk.instrs [mul_instruction];
          let mul_instr = (mul_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [mul_instr];
            (blocks, current_blk)
        | None -> failwith "#12: MUL instrction block current block doesn't exist." 
      end
    | ADD (cond, suffix, rd, rn, operand_type) ->
      let line_id = fresh_line () in
      let add_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk -> 
          current_blk.instrs <- List.append current_blk.instrs [add_instruction];
          let add_instr = (add_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [add_instr];
            (blocks, current_blk)
        | None -> failwith "#11: ADD instrction block current block doesn't exist." 
      end
    | SUB (cond, suffix, rd, rn, operand_type) ->
      let line_id = fresh_line () in
      let sub_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk -> 
          current_blk.instrs <- List.append current_blk.instrs [sub_instruction];
          let sub_instr = (sub_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [sub_instr];
            (blocks, current_blk)
        | None -> failwith "#10: SUB instrction block current block doesn't exist." 
      end
    | AND (cond, suffix, rd, rn, operand_type) ->
      let line_id = fresh_line () in
      let and_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk -> 
          current_blk.instrs <- List.append current_blk.instrs [and_instruction];
          let and_instr = (and_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [and_instr];
            (blocks, current_blk)
        | None -> failwith "#9: AND instrction block current block doesn't exist." 
      end
    | ORR (cond, suffix, rd, rn, operand_type) ->
      let line_id = fresh_line () in
      let or_instruction = (line_id, false, i) in
      begin
        match current_blk with
        | Some current_blk -> 
          current_blk.instrs <- List.append current_blk.instrs [or_instruction];
          let or_instr = (or_instruction, current_blk.id, current_blk.label) in
            current_blk.instrs_out <- List.append current_blk.instrs_out [or_instr];
            (blocks, current_blk)
        | None -> failwith "#8: Or instrction block current block doesn't exist." 
      end
    | _ -> failwith "#1: instruction not implemented in block generation"
  | _ -> failwith "#3"
