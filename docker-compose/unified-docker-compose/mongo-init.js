db.createUser(
    {
        user: "admin",
        pwd: "AuraSeltec",
        roles: [
            {
                role: "readWrite",
                db: "openhab"
            }
        ]
    }
);