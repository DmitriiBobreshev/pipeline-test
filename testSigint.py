import signal, sys, time

def cancelJob(signum, frame):
    for i in range(1000):
        print(i, signal.Signals(signum).name)
    time.sleep(10)
    sys.exit(1)

signal.signal(signal.SIGABRT, cancelJob)
signal.signal(signal.SIGHUP, cancelJob)
signal.signal(signal.SIGINT, cancelJob)
signal.signal(signal.SIGQUIT, cancelJob)
signal.signal(signal.SIGTERM, cancelJob)

for i in range(1000):
    time.sleep(500)
    print(i, "job started")
time.sleep(600)