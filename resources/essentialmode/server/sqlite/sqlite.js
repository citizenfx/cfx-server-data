//       Licensed under: AGPLv3        //
//  GNU AFFERO GENERAL PUBLIC LICENSE  //
//     Version 3, 19 November 2007     //

const updateUser = (identifier, newData) => {
    for(key in newData){
        emit("es_sqlite:updateUserData", identifier, key, newData[key])
    }
}

on("es_sqlite:updateUser", updateUser)