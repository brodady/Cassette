/// @ignore  (Internal) __CassetteDeck_ResumeSystem()
/// @desc    Resumes updates/un-suspends system (time continues to tick)
/// @self CassetteDeck
function __CassetteDeck_ResumeSystem() {
    time_source_resume(__timeSource);
};
