USING: kernel sequences grouping arrays assocs literals locals namespaces 
math math.vectors sorting io io.files io.encodings.ascii command-line tools.time ;
IN: mazes

CONSTANT: M0         32      ! empty cell
CONSTANT: M1         CHAR: # ! single mark cell
CONSTANT: M2         CHAR: . ! double mark cell
CONSTANT: MARK-TRANS H{ ${ M0 M1 } ${ M1 M2 } ${ M2 M2 } } 
CONSTANT: DIRECTIONS { { 1 0 } { 0 1 } { -1 0 } { 0 -1 } } 
CONSTANT: START-POS  { 0 1 }

: 2to1 ( line -- line ) "  " append 3 group [ 2 swap remove-nth ] map concat ;
: 1to2 ( line -- line ) 2 group [ dup last suffix ] map concat ;
: get-goal ( maze -- pos ) [ first length 2 - ] [ length 2 - ] bi 2array ;
: get-mark ( maze pos -- mark ) [ second ] [ first ] bi [ over nth ] bi@ 2nip ;
:: set-mark ( maze pos mark -- maze ) mark pos first pos second maze nth set-nth maze ;

:: passages ( maze pos -- passages ) 
    DIRECTIONS [ dup pos v+ maze swap get-mark 2array ] map 
    [ MARK-TRANS swap second of ] filter 
    [ second ] sort-with ;

:: tremaux-step ( maze dir pos -- maze dir pos ) 
    maze pos get-mark :> mark                          ! current position's mark
    pos dir v+ :> npos                                 ! new position
    maze npos get-mark :> nmark                        ! new mark at the new position
    maze npos passages first :> psg                    ! get the available passage
    psg first :> ndir                                  ! pick the new direction
    dir vneg ndir = [ M2 ] [ nmark ] if :> nmark1      ! check if turned around
    psg second M0 = [ M0 ] [ nmark1 ] if :> nmark2     ! check if junction has free passages
    maze mark M1 = nmark M1 = and                      ! already visited junction?
    [ dir vneg pos ] [ ndir npos ] if                  ! pick the final direction/position
    maze over MARK-TRANS nmark2 of set-mark drop ;     ! set the new mark

: tremaux-solve ( maze -- maze ) [let dup get-goal :> goal 
    { 1 0 } START-POS [ dup goal = ] [ tremaux-step ] until ] 2drop ;

: solve-file ( maze-file -- ) 
    ascii file-lines 
    [ 2to1 ] map 
    [ tremaux-solve ] time 
    [ 1to2 ] map 
    [ print ] each ;

: mazes ( -- ) command-line get 
    dup empty? [ drop "vocab:mazes/maze3.txt" ] [ first ] if 
    solve-file ; 

MAIN: mazes
