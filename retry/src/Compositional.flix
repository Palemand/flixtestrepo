import java.time.Duration;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;


enum NextAction {
    case Terminate
    case Retry(Int32)
}

