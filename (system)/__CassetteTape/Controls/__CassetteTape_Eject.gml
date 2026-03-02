// Feather ignore all
/// @ignore  (Internal) __CassetteTape_Eject()
/// @desc    Removes the tape from the deck, marking it for garbage collection.
/// @self __CassetteTape
function __CassetteTape_Eject() {
    if (__parent != undefined) {
        __parent.__RemoveChild(self);
    }

    __parent = undefined;
    __active = false;
    return self;
}
