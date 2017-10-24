# tvof-kiln
Contains the Kiln part of the TVOF resource

---

### UC-00

  **Summary:**  SUMMARY DESCRIPTION OF THE CASE    
  **Priority:**  PUT IN APPROPRIATE MOSCOW VALUE    
  **Use Frequency:**  CHOOSE FROM Always, Often, Sometimes, Rarely, Once    
  **Direct Actors:**  EG. ADMIN, EDITOR, PUBLIC    
  **Main Success Scenario:**
  1. STEP
  2. STEP
  3. ETC.

---

  [GUIDANCE FOR STEPS: Try to start each step with one of these action words:

login [as ROLE or USER]
Log into the system with a given user or a user of the given type. Usually usually only stated explicitly when the test case involves a workflow between different users.

visit LOCATION
Visit a page or GUI window. State the user's intention, don't say too much about UI choices that could change later. E.g., WRONG: "Press the 'Advanced...' button on the File | Page Setup dialog". RIGHT: "Visit the page margin configuration dialog".

enter INFORMATION
Fill in specific information. Try to state the information in some detail. E.g., WRONG: "Enter customer information." RIGHT: "Enter customer shipping address and discount code." Don't commit to details of a particular UI, i.e., don't name specific UI fields that might change later.

COMMAND
Describe a command that the user can tell the system to do. State the user's intent, not the label on a particular UI widget. This will usually be followed by a "see" step where the user sees a confirmation of their action. E.g., WRONG: "Control-P, OK". RIGHT: "Print the current document with default settings".

see CONTENT
The user should see the specified information on the currently presented web page or GUI window. Try to be specific about the information that is seen, but try not to refer to specific UI elements. E.g., WRONG: "see UserList.jsp" (what is the user supposed to notice on that page?) RIGHT: "see list of users with the newly added user in the list".

perform USE-CASE-NAME
This is like a subroutine call. The user will do all the steps of the named use case and then continue on with the next step of this use case.
]
