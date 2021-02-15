// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include "../inst/include/individual.h"
#include "../inst/include/individual_types.h"
#include <Rcpp.h>
#include <string>
#include <set>

using namespace Rcpp;

// create_bitset
Rcpp::XPtr<individual_index_t> create_bitset(size_t size);
RcppExport SEXP _individual_create_bitset(SEXP sizeSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< size_t >::type size(sizeSEXP);
    rcpp_result_gen = Rcpp::wrap(create_bitset(size));
    return rcpp_result_gen;
END_RCPP
}
// bitset_copy
Rcpp::XPtr<individual_index_t> bitset_copy(const Rcpp::XPtr<individual_index_t> b);
RcppExport SEXP _individual_bitset_copy(SEXP bSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type b(bSEXP);
    rcpp_result_gen = Rcpp::wrap(bitset_copy(b));
    return rcpp_result_gen;
END_RCPP
}
// bitset_insert
void bitset_insert(const Rcpp::XPtr<individual_index_t> b, std::vector<size_t> v);
RcppExport SEXP _individual_bitset_insert(SEXP bSEXP, SEXP vSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type b(bSEXP);
    Rcpp::traits::input_parameter< std::vector<size_t> >::type v(vSEXP);
    bitset_insert(b, v);
    return R_NilValue;
END_RCPP
}
// bitset_remove
void bitset_remove(const Rcpp::XPtr<individual_index_t> b, std::vector<size_t> v);
RcppExport SEXP _individual_bitset_remove(SEXP bSEXP, SEXP vSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type b(bSEXP);
    Rcpp::traits::input_parameter< std::vector<size_t> >::type v(vSEXP);
    bitset_remove(b, v);
    return R_NilValue;
END_RCPP
}
// bitset_size
size_t bitset_size(const Rcpp::XPtr<individual_index_t> b);
RcppExport SEXP _individual_bitset_size(SEXP bSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type b(bSEXP);
    rcpp_result_gen = Rcpp::wrap(bitset_size(b));
    return rcpp_result_gen;
END_RCPP
}
// bitset_max_size
size_t bitset_max_size(const Rcpp::XPtr<individual_index_t> b);
RcppExport SEXP _individual_bitset_max_size(SEXP bSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type b(bSEXP);
    rcpp_result_gen = Rcpp::wrap(bitset_max_size(b));
    return rcpp_result_gen;
END_RCPP
}
// bitset_and
void bitset_and(const Rcpp::XPtr<individual_index_t> a, const Rcpp::XPtr<individual_index_t> b);
RcppExport SEXP _individual_bitset_and(SEXP aSEXP, SEXP bSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type a(aSEXP);
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type b(bSEXP);
    bitset_and(a, b);
    return R_NilValue;
END_RCPP
}
// bitset_not
Rcpp::XPtr<individual_index_t> bitset_not(const Rcpp::XPtr<individual_index_t> b);
RcppExport SEXP _individual_bitset_not(SEXP bSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type b(bSEXP);
    rcpp_result_gen = Rcpp::wrap(bitset_not(b));
    return rcpp_result_gen;
END_RCPP
}
// bitset_or
void bitset_or(const Rcpp::XPtr<individual_index_t> a, const Rcpp::XPtr<individual_index_t> b);
RcppExport SEXP _individual_bitset_or(SEXP aSEXP, SEXP bSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type a(aSEXP);
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type b(bSEXP);
    bitset_or(a, b);
    return R_NilValue;
END_RCPP
}
// bitset_sample
void bitset_sample(const Rcpp::XPtr<individual_index_t> b, double rate);
RcppExport SEXP _individual_bitset_sample(SEXP bSEXP, SEXP rateSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type b(bSEXP);
    Rcpp::traits::input_parameter< double >::type rate(rateSEXP);
    bitset_sample(b, rate);
    return R_NilValue;
END_RCPP
}
// bitset_to_vector
std::vector<size_t> bitset_to_vector(const Rcpp::XPtr<individual_index_t> b);
RcppExport SEXP _individual_bitset_to_vector(SEXP bSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type b(bSEXP);
    rcpp_result_gen = Rcpp::wrap(bitset_to_vector(b));
    return rcpp_result_gen;
END_RCPP
}
// create_categorical_variable
Rcpp::XPtr<CategoricalVariable> create_categorical_variable(const std::vector<std::string>& categories, const std::vector<std::string>& values);
RcppExport SEXP _individual_create_categorical_variable(SEXP categoriesSEXP, SEXP valuesSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const std::vector<std::string>& >::type categories(categoriesSEXP);
    Rcpp::traits::input_parameter< const std::vector<std::string>& >::type values(valuesSEXP);
    rcpp_result_gen = Rcpp::wrap(create_categorical_variable(categories, values));
    return rcpp_result_gen;
END_RCPP
}
// categorical_variable_queue_update
void categorical_variable_queue_update(Rcpp::XPtr<CategoricalVariable> variable, const std::string& value, Rcpp::XPtr<individual_index_t> index);
RcppExport SEXP _individual_categorical_variable_queue_update(SEXP variableSEXP, SEXP valueSEXP, SEXP indexSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::XPtr<CategoricalVariable> >::type variable(variableSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type value(valueSEXP);
    Rcpp::traits::input_parameter< Rcpp::XPtr<individual_index_t> >::type index(indexSEXP);
    categorical_variable_queue_update(variable, value, index);
    return R_NilValue;
END_RCPP
}
// categorical_variable_get_index_of
Rcpp::XPtr<individual_index_t> categorical_variable_get_index_of(Rcpp::XPtr<CategoricalVariable> variable, const std::vector<std::string>& values);
RcppExport SEXP _individual_categorical_variable_get_index_of(SEXP variableSEXP, SEXP valuesSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::XPtr<CategoricalVariable> >::type variable(variableSEXP);
    Rcpp::traits::input_parameter< const std::vector<std::string>& >::type values(valuesSEXP);
    rcpp_result_gen = Rcpp::wrap(categorical_variable_get_index_of(variable, values));
    return rcpp_result_gen;
END_RCPP
}
// categorical_variable_queue_update_vector
void categorical_variable_queue_update_vector(Rcpp::XPtr<CategoricalVariable> variable, const std::string& value, std::vector<size_t>& index);
RcppExport SEXP _individual_categorical_variable_queue_update_vector(SEXP variableSEXP, SEXP valueSEXP, SEXP indexSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::XPtr<CategoricalVariable> >::type variable(variableSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type value(valueSEXP);
    Rcpp::traits::input_parameter< std::vector<size_t>& >::type index(indexSEXP);
    categorical_variable_queue_update_vector(variable, value, index);
    return R_NilValue;
END_RCPP
}
// categorical_variable_update
void categorical_variable_update(Rcpp::XPtr<CategoricalVariable> variable);
RcppExport SEXP _individual_categorical_variable_update(SEXP variableSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::XPtr<CategoricalVariable> >::type variable(variableSEXP);
    categorical_variable_update(variable);
    return R_NilValue;
END_RCPP
}
// dummy
void dummy();
static SEXP _individual_dummy_try() {
BEGIN_RCPP
    dummy();
    return R_NilValue;
END_RCPP_RETURN_ERROR
}
RcppExport SEXP _individual_dummy() {
    SEXP rcpp_result_gen;
    {
        Rcpp::RNGScope rcpp_rngScope_gen;
        rcpp_result_gen = PROTECT(_individual_dummy_try());
    }
    Rboolean rcpp_isInterrupt_gen = Rf_inherits(rcpp_result_gen, "interrupted-error");
    if (rcpp_isInterrupt_gen) {
        UNPROTECT(1);
        Rf_onintr();
    }
    bool rcpp_isLongjump_gen = Rcpp::internal::isLongjumpSentinel(rcpp_result_gen);
    if (rcpp_isLongjump_gen) {
        Rcpp::internal::resumeJump(rcpp_result_gen);
    }
    Rboolean rcpp_isError_gen = Rf_inherits(rcpp_result_gen, "try-error");
    if (rcpp_isError_gen) {
        SEXP rcpp_msgSEXP_gen = Rf_asChar(rcpp_result_gen);
        UNPROTECT(1);
        Rf_error(CHAR(rcpp_msgSEXP_gen));
    }
    UNPROTECT(1);
    return rcpp_result_gen;
}
// create_double_variable
Rcpp::XPtr<DoubleVariable> create_double_variable(const std::vector<double>& values);
RcppExport SEXP _individual_create_double_variable(SEXP valuesSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const std::vector<double>& >::type values(valuesSEXP);
    rcpp_result_gen = Rcpp::wrap(create_double_variable(values));
    return rcpp_result_gen;
END_RCPP
}
// double_variable_get_values
std::vector<double> double_variable_get_values(Rcpp::XPtr<DoubleVariable> variable);
RcppExport SEXP _individual_double_variable_get_values(SEXP variableSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::XPtr<DoubleVariable> >::type variable(variableSEXP);
    rcpp_result_gen = Rcpp::wrap(double_variable_get_values(variable));
    return rcpp_result_gen;
END_RCPP
}
// double_variable_get_values_at_index
std::vector<double> double_variable_get_values_at_index(Rcpp::XPtr<DoubleVariable> variable, Rcpp::XPtr<individual_index_t> index);
RcppExport SEXP _individual_double_variable_get_values_at_index(SEXP variableSEXP, SEXP indexSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::XPtr<DoubleVariable> >::type variable(variableSEXP);
    Rcpp::traits::input_parameter< Rcpp::XPtr<individual_index_t> >::type index(indexSEXP);
    rcpp_result_gen = Rcpp::wrap(double_variable_get_values_at_index(variable, index));
    return rcpp_result_gen;
END_RCPP
}
// double_variable_get_values_at_index_vector
std::vector<double> double_variable_get_values_at_index_vector(Rcpp::XPtr<DoubleVariable> variable, std::vector<size_t> index);
RcppExport SEXP _individual_double_variable_get_values_at_index_vector(SEXP variableSEXP, SEXP indexSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::XPtr<DoubleVariable> >::type variable(variableSEXP);
    Rcpp::traits::input_parameter< std::vector<size_t> >::type index(indexSEXP);
    rcpp_result_gen = Rcpp::wrap(double_variable_get_values_at_index_vector(variable, index));
    return rcpp_result_gen;
END_RCPP
}
// double_variable_queue_fill
void double_variable_queue_fill(Rcpp::XPtr<DoubleVariable> variable, const std::vector<double> value);
RcppExport SEXP _individual_double_variable_queue_fill(SEXP variableSEXP, SEXP valueSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::XPtr<DoubleVariable> >::type variable(variableSEXP);
    Rcpp::traits::input_parameter< const std::vector<double> >::type value(valueSEXP);
    double_variable_queue_fill(variable, value);
    return R_NilValue;
END_RCPP
}
// double_variable_queue_update
void double_variable_queue_update(Rcpp::XPtr<DoubleVariable> variable, const std::vector<double> value, std::vector<size_t> index);
RcppExport SEXP _individual_double_variable_queue_update(SEXP variableSEXP, SEXP valueSEXP, SEXP indexSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::XPtr<DoubleVariable> >::type variable(variableSEXP);
    Rcpp::traits::input_parameter< const std::vector<double> >::type value(valueSEXP);
    Rcpp::traits::input_parameter< std::vector<size_t> >::type index(indexSEXP);
    double_variable_queue_update(variable, value, index);
    return R_NilValue;
END_RCPP
}
// double_variable_update
void double_variable_update(Rcpp::XPtr<DoubleVariable> variable);
RcppExport SEXP _individual_double_variable_update(SEXP variableSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::XPtr<DoubleVariable> >::type variable(variableSEXP);
    double_variable_update(variable);
    return R_NilValue;
END_RCPP
}
// create_event
Rcpp::XPtr<EventBase> create_event();
RcppExport SEXP _individual_create_event() {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    rcpp_result_gen = Rcpp::wrap(create_event());
    return rcpp_result_gen;
END_RCPP
}
// create_targeted_event
Rcpp::XPtr<EventBase> create_targeted_event(size_t size);
RcppExport SEXP _individual_create_targeted_event(SEXP sizeSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< size_t >::type size(sizeSEXP);
    rcpp_result_gen = Rcpp::wrap(create_targeted_event(size));
    return rcpp_result_gen;
END_RCPP
}
// event_tick
void event_tick(const Rcpp::XPtr<EventBase> event);
RcppExport SEXP _individual_event_tick(SEXP eventSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<EventBase> >::type event(eventSEXP);
    event_tick(event);
    return R_NilValue;
END_RCPP
}
// event_schedule
void event_schedule(const Rcpp::XPtr<Event> event, std::vector<double> delays);
RcppExport SEXP _individual_event_schedule(SEXP eventSEXP, SEXP delaysSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<Event> >::type event(eventSEXP);
    Rcpp::traits::input_parameter< std::vector<double> >::type delays(delaysSEXP);
    event_schedule(event, delays);
    return R_NilValue;
END_RCPP
}
// event_clear_schedule
void event_clear_schedule(const Rcpp::XPtr<Event> event);
RcppExport SEXP _individual_event_clear_schedule(SEXP eventSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<Event> >::type event(eventSEXP);
    event_clear_schedule(event);
    return R_NilValue;
END_RCPP
}
// targeted_event_clear_schedule_vector
void targeted_event_clear_schedule_vector(const Rcpp::XPtr<TargetedEvent> event, std::vector<size_t> target);
RcppExport SEXP _individual_targeted_event_clear_schedule_vector(SEXP eventSEXP, SEXP targetSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<TargetedEvent> >::type event(eventSEXP);
    Rcpp::traits::input_parameter< std::vector<size_t> >::type target(targetSEXP);
    targeted_event_clear_schedule_vector(event, target);
    return R_NilValue;
END_RCPP
}
// targeted_event_clear_schedule
void targeted_event_clear_schedule(const Rcpp::XPtr<TargetedEvent> event, const Rcpp::XPtr<individual_index_t> target);
RcppExport SEXP _individual_targeted_event_clear_schedule(SEXP eventSEXP, SEXP targetSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<TargetedEvent> >::type event(eventSEXP);
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type target(targetSEXP);
    targeted_event_clear_schedule(event, target);
    return R_NilValue;
END_RCPP
}
// event_get_scheduled
Rcpp::XPtr<individual_index_t> event_get_scheduled(const Rcpp::XPtr<TargetedEvent> event);
RcppExport SEXP _individual_event_get_scheduled(SEXP eventSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<TargetedEvent> >::type event(eventSEXP);
    rcpp_result_gen = Rcpp::wrap(event_get_scheduled(event));
    return rcpp_result_gen;
END_RCPP
}
// targeted_event_schedule
void targeted_event_schedule(const Rcpp::XPtr<TargetedEvent> event, const Rcpp::XPtr<individual_index_t> target, double delay);
RcppExport SEXP _individual_targeted_event_schedule(SEXP eventSEXP, SEXP targetSEXP, SEXP delaySEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<TargetedEvent> >::type event(eventSEXP);
    Rcpp::traits::input_parameter< const Rcpp::XPtr<individual_index_t> >::type target(targetSEXP);
    Rcpp::traits::input_parameter< double >::type delay(delaySEXP);
    targeted_event_schedule(event, target, delay);
    return R_NilValue;
END_RCPP
}
// targeted_event_schedule_vector
void targeted_event_schedule_vector(const Rcpp::XPtr<TargetedEvent> event, std::vector<size_t> target, double delay);
RcppExport SEXP _individual_targeted_event_schedule_vector(SEXP eventSEXP, SEXP targetSEXP, SEXP delaySEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<TargetedEvent> >::type event(eventSEXP);
    Rcpp::traits::input_parameter< std::vector<size_t> >::type target(targetSEXP);
    Rcpp::traits::input_parameter< double >::type delay(delaySEXP);
    targeted_event_schedule_vector(event, target, delay);
    return R_NilValue;
END_RCPP
}
// targeted_event_schedule_multi_delay
void targeted_event_schedule_multi_delay(const Rcpp::XPtr<TargetedEvent> event, std::vector<size_t> target, const std::vector<double> delay);
RcppExport SEXP _individual_targeted_event_schedule_multi_delay(SEXP eventSEXP, SEXP targetSEXP, SEXP delaySEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<TargetedEvent> >::type event(eventSEXP);
    Rcpp::traits::input_parameter< std::vector<size_t> >::type target(targetSEXP);
    Rcpp::traits::input_parameter< const std::vector<double> >::type delay(delaySEXP);
    targeted_event_schedule_multi_delay(event, target, delay);
    return R_NilValue;
END_RCPP
}
// event_get_timestep
size_t event_get_timestep(const Rcpp::XPtr<EventBase> event);
RcppExport SEXP _individual_event_get_timestep(SEXP eventSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<EventBase> >::type event(eventSEXP);
    rcpp_result_gen = Rcpp::wrap(event_get_timestep(event));
    return rcpp_result_gen;
END_RCPP
}
// event_should_trigger
bool event_should_trigger(const Rcpp::XPtr<EventBase> event);
RcppExport SEXP _individual_event_should_trigger(SEXP eventSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<EventBase> >::type event(eventSEXP);
    rcpp_result_gen = Rcpp::wrap(event_should_trigger(event));
    return rcpp_result_gen;
END_RCPP
}
// event_get_target
Rcpp::XPtr<individual_index_t> event_get_target(const Rcpp::XPtr<TargetedEvent> event);
RcppExport SEXP _individual_event_get_target(SEXP eventSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const Rcpp::XPtr<TargetedEvent> >::type event(eventSEXP);
    rcpp_result_gen = Rcpp::wrap(event_get_target(event));
    return rcpp_result_gen;
END_RCPP
}
// execute_process
void execute_process(Rcpp::XPtr<process_t> process, size_t timestep);
RcppExport SEXP _individual_execute_process(SEXP processSEXP, SEXP timestepSEXP) {
BEGIN_RCPP
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< Rcpp::XPtr<process_t> >::type process(processSEXP);
    Rcpp::traits::input_parameter< size_t >::type timestep(timestepSEXP);
    execute_process(process, timestep);
    return R_NilValue;
END_RCPP
}

// validate (ensure exported C++ functions exist before calling them)
static int _individual_RcppExport_validate(const char* sig) { 
    static std::set<std::string> signatures;
    if (signatures.empty()) {
        signatures.insert("void(*dummy)()");
    }
    return signatures.find(sig) != signatures.end();
}

// registerCCallable (register entry points for exported C++ functions)
RcppExport SEXP _individual_RcppExport_registerCCallable() { 
    R_RegisterCCallable("individual", "_individual_dummy", (DL_FUNC)_individual_dummy_try);
    R_RegisterCCallable("individual", "_individual_RcppExport_validate", (DL_FUNC)_individual_RcppExport_validate);
    return R_NilValue;
}

RcppExport SEXP run_testthat_tests();

static const R_CallMethodDef CallEntries[] = {
    {"_individual_create_bitset", (DL_FUNC) &_individual_create_bitset, 1},
    {"_individual_bitset_copy", (DL_FUNC) &_individual_bitset_copy, 1},
    {"_individual_bitset_insert", (DL_FUNC) &_individual_bitset_insert, 2},
    {"_individual_bitset_remove", (DL_FUNC) &_individual_bitset_remove, 2},
    {"_individual_bitset_size", (DL_FUNC) &_individual_bitset_size, 1},
    {"_individual_bitset_max_size", (DL_FUNC) &_individual_bitset_max_size, 1},
    {"_individual_bitset_and", (DL_FUNC) &_individual_bitset_and, 2},
    {"_individual_bitset_not", (DL_FUNC) &_individual_bitset_not, 1},
    {"_individual_bitset_or", (DL_FUNC) &_individual_bitset_or, 2},
    {"_individual_bitset_sample", (DL_FUNC) &_individual_bitset_sample, 2},
    {"_individual_bitset_to_vector", (DL_FUNC) &_individual_bitset_to_vector, 1},
    {"_individual_create_categorical_variable", (DL_FUNC) &_individual_create_categorical_variable, 2},
    {"_individual_categorical_variable_queue_update", (DL_FUNC) &_individual_categorical_variable_queue_update, 3},
    {"_individual_categorical_variable_get_index_of", (DL_FUNC) &_individual_categorical_variable_get_index_of, 2},
    {"_individual_categorical_variable_queue_update_vector", (DL_FUNC) &_individual_categorical_variable_queue_update_vector, 3},
    {"_individual_categorical_variable_update", (DL_FUNC) &_individual_categorical_variable_update, 1},
    {"_individual_dummy", (DL_FUNC) &_individual_dummy, 0},
    {"_individual_create_double_variable", (DL_FUNC) &_individual_create_double_variable, 1},
    {"_individual_double_variable_get_values", (DL_FUNC) &_individual_double_variable_get_values, 1},
    {"_individual_double_variable_get_values_at_index", (DL_FUNC) &_individual_double_variable_get_values_at_index, 2},
    {"_individual_double_variable_get_values_at_index_vector", (DL_FUNC) &_individual_double_variable_get_values_at_index_vector, 2},
    {"_individual_double_variable_queue_fill", (DL_FUNC) &_individual_double_variable_queue_fill, 2},
    {"_individual_double_variable_queue_update", (DL_FUNC) &_individual_double_variable_queue_update, 3},
    {"_individual_double_variable_update", (DL_FUNC) &_individual_double_variable_update, 1},
    {"_individual_create_event", (DL_FUNC) &_individual_create_event, 0},
    {"_individual_create_targeted_event", (DL_FUNC) &_individual_create_targeted_event, 1},
    {"_individual_event_tick", (DL_FUNC) &_individual_event_tick, 1},
    {"_individual_event_schedule", (DL_FUNC) &_individual_event_schedule, 2},
    {"_individual_event_clear_schedule", (DL_FUNC) &_individual_event_clear_schedule, 1},
    {"_individual_targeted_event_clear_schedule_vector", (DL_FUNC) &_individual_targeted_event_clear_schedule_vector, 2},
    {"_individual_targeted_event_clear_schedule", (DL_FUNC) &_individual_targeted_event_clear_schedule, 2},
    {"_individual_event_get_scheduled", (DL_FUNC) &_individual_event_get_scheduled, 1},
    {"_individual_targeted_event_schedule", (DL_FUNC) &_individual_targeted_event_schedule, 3},
    {"_individual_targeted_event_schedule_vector", (DL_FUNC) &_individual_targeted_event_schedule_vector, 3},
    {"_individual_targeted_event_schedule_multi_delay", (DL_FUNC) &_individual_targeted_event_schedule_multi_delay, 3},
    {"_individual_event_get_timestep", (DL_FUNC) &_individual_event_get_timestep, 1},
    {"_individual_event_should_trigger", (DL_FUNC) &_individual_event_should_trigger, 1},
    {"_individual_event_get_target", (DL_FUNC) &_individual_event_get_target, 1},
    {"_individual_execute_process", (DL_FUNC) &_individual_execute_process, 2},
    {"_individual_RcppExport_registerCCallable", (DL_FUNC) &_individual_RcppExport_registerCCallable, 0},
    {"run_testthat_tests", (DL_FUNC) &run_testthat_tests, 0},
    {NULL, NULL, 0}
};

RcppExport void R_init_individual(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
