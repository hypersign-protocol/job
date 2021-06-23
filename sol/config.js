module.exports = {
    TOTAL_SUPPLY: 50000000,
    TOKEN_NAME: "Hypersign Identity Token",
    TOKEN_SYMBOL: "HID",
    DECIMALS: 18,
    vesting:{
        _token : "0x9491fae7A7CAAF993EAcB34a8Fc4848c9d1AB8C6", // HID token address
        _beneficiary : "0xb516f8874633e2f4Ccb1F1Ba843EDC99197D065A", // address of beneficiary
        _startTime :  Math.ceil((new Date().getTime() + 120000) / 1000),    // start time in seconds (epoch time)
        _cliffDuration : 120, // cliff duration in seconds
        _waitDuration : 120, // wait duration after cliff in seconds
        _payOutPercentage : 2000, // % (in multiple of 100 i.e 12.50% = 1250) funds released in each interval.
        _payOutInterval : 120, // intervals (in seconds) at which funds will be released
        _revocable : true
    }
}
