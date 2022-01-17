This class is a singleton wrapper around AVPlayer. It plays audio files from URLs, 
both locally and remotely. The main reason I made it a singeton is so that only 
one AVPlayer can be trying to play at a time. As a result of being a singlton, it can be 
called from anywhere in your codebase very easily.

In order to be a good citizen of iOS, you should setup the audio session, preferable when
your app starts, before playing audio. Setup the audio session like this:

let audioSession = AVAudioSession.sharedInstance()
do {
    try audioSession.setCategory(.playback)
} 
catch {
    print("Setting category to AVAudioSessionCategoryPlayback failed.")
}
    

