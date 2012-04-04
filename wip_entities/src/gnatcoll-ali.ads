------------------------------------------------------------------------------
--                                  G P S                                   --
--                                                                          --
--                     Copyright (C) 2011-2012, AdaCore                     --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.  You should have  received  a copy of the GNU --
-- General  Public  License  distributed  with  this  software;   see  file --
-- COPYING3.  If not, go to http://www.gnu.org/licenses for a complete copy --
-- of the license.                                                          --
------------------------------------------------------------------------------

--  This package provides support for parsing the .ali and .gli files that
--  are generated by GNAT and gcc. In particular, those files contain
--  information that can be used to do cross-references for entities (going
--  from references to their declaration for instance).
--
--  A typical example would be:
--
--  declare
--     Session : Session_Type;
--  begin
--     GNATCOLL.SQL.Sessions.Setup
--        (Descr   => GNATCOLL.SQL.Sqlite.Setup (":memory:"));
--     Session := Get_New_Session;
--
--     ... parse the project through GNATCOLL.Projects
--
--     Create_Database (Session.DB);
--     Parse_All_LI_Files (Session, ...);
--   end;

with GNATCOLL.Projects;     use GNATCOLL.Projects;
with GNATCOLL.SQL.Exec;     use GNATCOLL.SQL.Exec;
with GNATCOLL.SQL.Sessions; use GNATCOLL.SQL.Sessions;
with GNATCOLL.VFS;

package GNATCOLL.ALI is

   function Parse_All_LI_Files
     (Session : Session_Type;
      Tree    : Project_Tree;
      Project : Project_Type;
      Destroy_Indexes : Boolean := False) return Boolean;
   --  Parse all the LI files for the project, and stores them in the
   --  database.
   --  If Destroy_Indexes is True, then some of the database indexes will be
   --  temporarily disabled and then recreated in the end. This will be faster
   --  when doing major changes, but will be slower otherwise.
   --
   --  Return True if at least one LI was updated.

   procedure Parse_All_LI_Files_With_Backup
     (Session      : Session_Type;
      Tree         : Project_Tree;
      Project      : Project_Type;
      From_DB_Name : String := "";
      To_DB_Name   : String := "");
   --  Same as above, but the database in Session.DB is first initialized by
   --  copying the database from From_DB_Name (if one exists).
   --  On exit, the in-memory database is copied back to To_DB_Name if that
   --  file is writable and the parameter is not the empty string.
   --  As such, it is possible to generate an entities database as part of a
   --  nightly build of an application, in a read-only area. Then each user's
   --  database is initially copied from that nightly database, and then can
   --  either be kept in memory (passing "" for To_DB_Name) or dumped back to
   --  a local user-writable file.
   --
   --  If Session.DB is an in-memory database, this procedure will be faster
   --  than directly modifying the database on the disk (through a call to
   --  Parse_All_LI_Files) when lots of changes need to be made.
   --  Otherwise, it will be slower since dumping the in-memory database to the
   --  disk is likely to take several seconds.
   --
   --  When no using sqlite, this procedure behaves the same as
   --  Parse_All_LI_Files, and cannot initialize a database from another one.

   procedure Create_Database
     (Connection      : access Database_Connection_Record'Class;
      DB_Schema_Descr : GNATCOLL.VFS.Virtual_File;
      Initial_Data    : GNATCOLL.VFS.Virtual_File);
   --  Create the database tables and initial contents.
   --  Behavior is undefined if the database is not empty initially.
   --  DB_Schema_Descr is the file that contains the description of the
   --  entities database schema.
   --  ??? We should not rely on an external file for this. Perhaps GNATCOLL
   --  could generate some code to create the GNATCOLL.SQL.Inspect.DB_Schema
   --  in the code ?

end GNATCOLL.ALI;
