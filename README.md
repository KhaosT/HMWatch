HMWatch
==
A project created to try new APIs in watchOS 2.0

Known Issues
--
- This may not work with Watch Simulator since HomeKit doesn't sync between iOS Simulator and watchOS Simulator (at least in Seed 1)

- On real watchOS device, sometime HMHomeManager will report that there is no home in device database. Currently there isn't a reliable workaround (but you can try to add and remove a home on paired iOS device). Please try to file a bug at https://bugreport.apple.com so Apple can fix that in future release.

- When the Watch is connected to paired iPhone, all the HomeKit commands will get rerouted to iPhone. In iOS 9.0 Seed 1, there might be a huge delay between change value on the Watch and the accessory get value change command. Putting paired iPhone into airplane mode will force Apple Watch to connect to accessories directly (which is much faster)
