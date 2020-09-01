/*
 * Log.h
 *
 *  Created on: 5 Mar 2020
 *      Author: giovanni
 *
 *  Adapted from https://stackoverflow.com/a/32262143/1613962
 */

#ifndef SRC_LOG_H_
#define SRC_LOG_H_

#include <Rcpp.h>
#include <string>

enum class log_level {
    debug,
    info,
    warn,
    error
};

struct structlog {
    bool headers = true;
    log_level level = log_level::warn;
    std::ostream& output = Rcpp::Rcout;
};

extern structlog LOGCFG;

class Log {
public:
    Log() {}
    Log(log_level level): msglevel(level) {}
    std::ostream& get()
    {
        if (msglevel >= LOGCFG.level) {
            LOGCFG.output.clear();
        } else {
            LOGCFG.output.setstate(std::ios_base::badbit);
        }

        if(LOGCFG.headers) {
            LOGCFG.output << "[" << get_label(msglevel) << "]" << '\t';
        }
        return LOGCFG.output;
    }
private:
    log_level msglevel = log_level::debug;
    std::string get_label(log_level level) {
        std::string label;
        switch(level) {
            case log_level::debug: label = "DEBUG"; break;
            case log_level::info:  label = "INFO "; break;
            case log_level::warn:  label = "WARN "; break;
            case log_level::error: label = "ERROR"; break;
        }
        return label;
    }
};

#endif /* SRC_LOG_H_ */
