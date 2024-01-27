// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @dev Revert with an error when an account being called as an assumed
 *      contract does not have code and returns no data.
 * @param account The account that should contain code.
 */
   error NoContract(address account);
   error Address_Is_A_Contract(address account);
   error Address_Is_A_Not_Contract(address account);
   error Address_Is_Blacklist(address account);

   error Address_Cannot_Be_Zero();
   error Insufficient_Allowance();
   error Insufficient_Balance();
   error User_Already_Staked();
   error User_Not_Expired();
   error User_Not_Staker();
   error User_Is_Member();
   error User_Is_Staker();
   error Not_Authorized();
   error Invalid_Action();
   error Overflow_0x11();
   error Invalid_Price();
   error Paused();
    
    


    