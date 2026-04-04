def retryExample(): Unit \ {} = {
    let pol = Retry.combine(Retry.limitRetries(5), Retry.constantBackoff(Time.Duration.milliseconds(100)));
    //showcasing how the simple retry part of the resillience library works
    let result = run {
        Net.Http.get("fails.fail")
    } with httpWithRetry
    with Retry.handle(pol)
    with Net.Http.handle;
    ???
}