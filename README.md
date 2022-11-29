# qb-apartments
Apartments System for QB-Core Framework :office:

## Dependencies
- [qb-core](https://github.com/Qbox-project/qb-core)
- [qb-clothing](https://github.com/Qbox-project/qb-clothing) - To save outfits
- [qb-houses](https://github.com/Qbox-project/qb-houses) - House logic
- [qb-interior](https://github.com/Qbox-project/qb-interior) - Interior logic
- [qb-weathersync](https://github.com/Qbox-project/qb-weathersync) - To desync weather while inside
- [qb-spawn](https://github.com/Qbox-project/qb-spawn) - To spawn the player at apartment if last location was in apartment

## Screenshots
![Inside Apartment](https://i.imgur.com/mp3XL4Y.jpg)
![Inside Apartment](https://i.imgur.com/3DH9RFw.jpg)
![Enter Apartment](https://imgur.com/1giGyt1.png)
![Stash](https://imgur.com/t6crf4c.png)
![Saved Outfits](https://imgur.com/I0YLuQA.png)
![Log Out](https://imgur.com/q1Yx3nS.png)

## Features
- Door Bell
- Stash
- Log Out Marker
- Saved Outfits

## Installation
### Manual
- Download the script and put it in the `[qb]` directory.
- Import `qb-apartments.sql` in your database
- Add the following code to your server.cfg/resouces.cfg
```
ensure qb-core
ensure qb-interior
ensure qb-weathersync
ensure qb-clothing
ensure qb-houses
ensure qb-spawn
ensure qb-apartments
```