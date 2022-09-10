/* Cabin Channel command */
mtype { stop, up, down };

/* Cabin Status */
mtype { moving_up, moving_down, standing }

/* Door Channel command */
mtype { open, close }

/* Cabin Status */
mtype { closed, opened }

/* Button Channel */
chan b_request = [3] of { int };
chan b_reply = [0] of { int };

/* Cabin Channel */
chan c_request = [0] of { mtype };
chan c_reply = [0] of { int };

/* Door Channel */
chan d_request = [0] of { mtype };
chan d_reply = [0] of { bool };

/* Button process */
proctype Button(int n_floor){

    int n_button;
    bool setted = false;

end:do
    
    :: (setted != true  && nfull(b_request)) ->
pt:     atomic{
            setted = true;
            b_request ! n_floor;
        } 
    
    :: b_reply ? n_button -> 
        (n_button == n_floor) -> 
pf:         setted = false;

    od

}

/* Cabin process */
proctype Cabin(){

    mtype status = standing;
    int actual_n_floor;

end:do

    :: c_request ? up -> 

        atomic {
            actual_n_floor++;
cs_up:      status = moving_up;
            c_reply ! actual_n_floor;
        }

    :: c_request ? down -> 
        atomic {
            actual_n_floor--;
cs_dw:      status = moving_down;
            c_reply ! actual_n_floor;
        }

    :: c_request ? stop -> 

        
        atomic{
            if
            :: status == moving_up -> actual_n_floor++;
            :: status == moving_down -> actual_n_floor--;
            fi;
cs_s:       status = standing;
            c_reply ! actual_n_floor;
        }

    od
}

/* Door process */
proctype Door(){

    mtype status = closed;

end:do

    :: d_request ? open ->  
        
ds_o:   atomic{
            status = opened;
            d_reply ! true;
        }
        

    :: d_request ? close ->    
        
ds_c:   atomic{
            status = closed;
            d_reply ! true;
        }
        

    od
}

/* Controller process */
proctype Controller(){

    int req_floor;
    int actual_n_floor = 1;

end:do

    :: b_request ? req_floor -> 
        do
        :: actual_n_floor < req_floor ->
            if
            :: actual_n_floor < req_floor ->
                atomic{
                    d_request ! close;
                    c_request ! up;
                }
                

            :: actual_n_floor > req_floor ->
                atomic{
                    d_request ! close;
                    c_request ! down;
                }
                
atReqFlor:  :: else
                atomic{
                    c_request ! stop;
                    d_request ! open;
                }

            fi

            c_reply ? actual_n_floor;
            d_reply ? _;

        od

        b_reply ! req_floor

    od
}

/* Init process */
init {
    atomic{
        run Button(1);
        run Button(2);
        run Button(3);
        run Cabin();
        run Door();
        run Controller()
    }
}

/* LTL Properties */

/* 1. Whenever the door is open the cabin must be standing */
ltl ltl1 { [](Door@ds_o -> Cabin@cs_s) }

/* 2. Whenever the cabin is moving the door must be closed */
ltl ltl2 { []((Cabin@cs_up || Cabin@cs_dw) -> Door@ds_c) }

/* 3. A button cannot remain pressed forever */
ltl ltl3 { [] (Button@pt -> <> Button@pf) }

/* 4. The door cannot remain open forever */
ltl ltl4 { [] (Door@ds_o -> <> Door@ds_c) } 

/* 5. The door cannot remain closed forever */
ltl ltl5 { [] (Door@ds_c -> <> Door@ds_o) }

/* 6. Whenever the button at floor x (x = 1, 2, 3) becomes pressed 
then the cabin will eventually be at floor x with the door open */
ltl ltl6 { [] (Button@pt -> <> (Controller@atReqFlor && Door@ds_o)) }

/* 7. Whenever no button is currently pressed and the button at floor x (x = 1, 2, 3)
becomes pressed and, afterwards, also the button at floor y (y =! x and y = 1, 2, 3) 
becomes pressed and, in the meanwhile, no other button becomes pressed then the cabin 
will be standing at floor x with the door open and, afterwards, the cabin will be standing 
at floor y with the door open and in the meanwhile the cabin will not be standing at any other 
floor different from y with the door open */

ltl ltl7 { 
    []  (
            ((((!Button[0]@pt && !Button[1]@pt && !Button[2]@pt) 
                U Button[0]@pt && !Button[1]@pt && !Button[2]@pt) 
                    U Button[1]@pt && !Button[2]@pt) -> 
                        <> ((Cabin@cs_s && Door@ds_o) -> Button[0]@pf) 
                            U ((Cabin@cs_s && Door@ds_o) -> Button[1]@pf)) &&

            ((((!Button[0]@pt && !Button[1]@pt && !Button[2]@pt) 
                U Button[0]@pt && !Button[1]@pt && !Button[2]@pt) 
                    U Button[2]@pt && !Button[1]@pt) -> 
                        <> ((Cabin@cs_s && Door@ds_o) -> Button[0]@pf) 
                            U ((Cabin@cs_s && Door@ds_o) -> Button[2]@pf)) && 

            ((((!Button[0]@pt && !Button[1]@pt && !Button[2]@pt) 
                U Button[1]@pt && !Button[0]@pt && !Button[2]@pt) 
                    U Button[0]@pt && !Button[2]@pt) -> 
                        <> ((Cabin@cs_s && Door@ds_o) -> Button[1]@pf) 
                            U ((Cabin@cs_s && Door@ds_o) -> Button[0]@pf)) &&   

            ((((!Button[0]@pt && !Button[1]@pt && !Button[2]@pt) 
                U Button[1]@pt && !Button[0]@pt && !Button[2]@pt) 
                    U Button[2]@pt && !Button[0]@pt) -> 
                        <> ((Cabin@cs_s && Door@ds_o) -> Button[1]@pf) 
                            U ((Cabin@cs_s && Door@ds_o) -> Button[2]@pf)) && 

            ((((!Button[0]@pt && !Button[1]@pt && !Button[2]@pt) 
                U Button[2]@pt && !Button[0]@pt && !Button[1]@pt) 
                    U Button[0]@pt && !Button[1]@pt) -> 
                        <> ((Cabin@cs_s && Door@ds_o) -> Button[2]@pf) 
                            U ((Cabin@cs_s && Door@ds_o) -> Button[0]@pf)) && 

            ((((!Button[0]@pt && !Button[1]@pt && !Button[2]@pt) 
                U Button[1]@pt && !Button[0]@pt && !Button[2]@pt) 
                    U Button[0]@pt && !Button[2]@pt) -> 
                        <> ((Cabin@cs_s && Door@ds_o) -> Button[1]@pf) 
                            U ((Cabin@cs_s && Door@ds_o) -> Button[0]@pf))

    )
}