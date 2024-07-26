void AudioCallbackHelper(int);
void TimerCallbackHelper();

void CallbackHelper() {
  TimerCallbackHelper();
  AudioCallbackHelper(0);
}
