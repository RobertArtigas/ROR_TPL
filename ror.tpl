#!==========================================================================
#! File:        ror.tpl
#! Purpose:     RubyOnRails Templates
#!
#! Copyright © 2009-2010 Roberto Artigas
#! All Rights Reserved World Wide
#!==========================================================================
#! A template set must have a #TEMPLATE section to name the set for
#! registration in the REGISTRY.TRF template registry file. At least one
#! registered template set must have #APPLICATION, #PROGRAM, and #MODULE
#! sections.
#!--------------------------------------------------------------------------
#!  #TEMPLATE( name, description ) [, PRIVATE ] [, FAMILY( sets ) ]
#!
#!  #TEMPLATE       Begins the Template set.
#!
#!  name            The name of the Template set which uniquely identifies
#!                  it for the Template Registry and Template Language
#!                  statements. This must be a valid Clarion label.
#!  description     A string constant describing the Template set for the
#!                  Template Registry and Application Generator.
#!  PRIVATE         Prevents re-generation from the Template Registry.
#!  FAMILY          Names the other Template sets in which the #TEMPLATE is
#!                  valid for use.
#!  sets            A string constant containing a comma delimited list of
#!                  the names of other Template sets in which the #TEMPLATE
#!                  is valid for use.
#!
#TEMPLATE(RubyOnRails,'2009.04.23 - RubyOnRails Templates'),FAMILY('RubyOnRails')
#!--------------------------------------------------------------------------
#! Help file associated with the template
 #HELP('rortpl.hlp')                                     
#!--------------------------------------------------------------------------
#!
#! The #SYSTEM statement marks the beginning of a section of Template code
#! which executes when the Template set is registered or loaded from the
#! template registry. Any #PROMPT statements in a #SYSTEM section appear on
#! the Application Options dialog, once the Template Registry has been
#! loaded (opened an .APP file).
#!
#!--------------------------------------------------------------------------
#! System Declarations
#!--------------------------------------------------------------------------
#SYSTEM
  #EQUATE(%TemplateVersion,'RubyOnRails v1.000')
#!==========================================================================
#!  #APPLICATION( description ) [, HLP( helpid ) ] [ APPLICATION( [ child(chain) ]
#!
#!  #APPLICATION    Begins source generation control section.
#!
#!  description     A string constant describing the application section.
#!  HLP             Specifies on-line help is available.
#!  helpid          A string constant containing the identifier to access
#!                  the Help system. This may be either a Help keyword or
#!                  "context string."
#!  APPLICATION     Tells the Application Generator to automatically place
#!                  the named) child template on every procedure.
#!  child(chain)    The name of a #EXTENSION with the PROCEDURE attribute to
#!                  automatically populate into every generated procedure
#!                  when the #EXTENSION with the APPLICATION attribute is
#!                  populated.
#!
#APPLICATION('RubyOnRails Application'),HLP('~RubyOnRailsTPLApplication')
#!--------------------------------------------------------------------------
#!
#! #PREPARE contains Template language statements to fix the global
#! multi-valued symbols to the values needed to process the #PROMPT or
#! #BUTTON statements. A #PREPARE section that precedes all the prompts
#! is executed once, before the prompts are added to the "Global"
#! propertiesa "pages" presented to the user.
#!
  #PREPARE

#! Add preparation statements for the #SHEET here..

  #ENDPREPARE
#!
#!--------------------------------------------------------------------------
#!
#! Declaring symbols that are global in scope can be done by adding #PROMPT
#! declarations in the "Global" #SHEET. The sheet can be organized into
#! "pages" by declaring a group of #TAB controls. The multiple #TAB
#! controls in the #SHEET structure define the "pages" displayed to the
#! user. These "pages" can be accessed from the "Global" properties button
#! or the "Global Properties.." menu option for the "Application" in the
#! main menu.
#!
  #SHEET
    #TAB ('&General'), HLP('~RubyOnRailsTPLApplication_General')
    #ENDTAB
  #ENDSHEET
#!
#!--------------------------------------------------------------------------
#!
#! Global Template Symbol Declarations.
#!
#!--------------------------------------------------------------------------
#!
  #DECLARE(%GlobalRegenerate)                               #! Global regeration flag
  #DECLARE(%ModuleGenerated,%Module),SAVE                   #! Generated MODULE flags
  #DECLARE(%GenerateModule)                                 #! Generate MODULE flag
  #DECLARE(%GenerateProgram)                                #! Generate PROGRAM flag
  #DECLARE(%SourceFile)                                     #! Source creation file
#!
#!------------------------------------------------------------------------------
#!
  #MESSAGE('Generating ' & %Application,0)                  #! Open the generation message box
#!
#!------------------------------------------------------------------------------
#!
#! Main Source Code Generation Loop.
#!
#!------------------------------------------------------------------------------
#! Edit Embedded Source Code
  #IF(%EditProcedure)                                       #! If editing embedded source code
    #CREATE(%EditFilename)                                  #!  Create procedure source file
    #FIND(%ModuleProcedure,%EditProcedure)                  #!  Find the procedure in the module
    #FIX(%Procedure,%ModuleProcedure)                       #!  Fix the procedure to the module procedure
    #MESSAGE('Generating Module:    ' & %Module,1)
    #MESSAGE('Generating Procedure: ' & %Procedure,2)
    #GENERATE(%Procedure)                                   #!  Generate the procedure for editing
    #CLOSE                                                  #!  Close the procedure source file
    #ABORT                                                  #!  Terminate source generation
  #ENDIF
#!------------------------------------------------------------------------------
#EMBED(%BeforeApplicationGeneration,'Application - Before Generation'),HIDE
#!------------------------------------------------------------------------------
  #IF(NOT %ConditionalGenerate OR %DictionaryChanged OR %RegistryChanged)
                                                            #! If not conditional generation
                                                            #! If dictionary has changed
                                                            #! If template registry has changed
    #SET(%GlobalRegenerate,%True)                           #!  Generate everything
    #FOR(%Module)                                           #!  For all application modules
      #SET(%ModuleGenerated,%False)                         #!   Set module flag to ungenerated
    #ENDFOR
  #ELSE                                                     #! Else if no global changes
    #SET(%GlobalRegenerate,%False)                          #!   Generate changed modules only
  #ENDIF
#!------------------------------------------------------------------------------
  #SET(%SourceFile,%Application & '.$$$')                   #! Set the temp source file name
#!------------------------------------------------------------------------------
  #FOR(%Module),WHERE(%Module <> %Program)                  #! For all member modules
    #MESSAGE('Generating Module:    ' & %Module,1)
    #SET(%GenerateModule,%True)                             #!  Set module to be generated
    #IF(%ModuleChanged)                                     #!  If module has been changed
    #ELSIF(%GlobalRegenerate)                               #!  If generating everything
    #ELSIF(NOT %ModuleGenerated)                            #!  If module flagged as ungenerated
    #ELSIF(NOT FILEEXISTS(%Module))                         #!  If module does not exist
    #ELSIF(%ModuleExternal)                                 #!  If module is external source
      #SET(%GenerateModule,%False)                          #!   Cancel module generation
    #ELSE                                                   #!  Else no other checks
      #SET(%GenerateModule,%False)                          #!   Cancel module generation
    #ENDIF
    #IF(%GenerateModule)                                    #! If module to be generated
      #SET(%ModuleGenerated,%False)                         #!  Set module flag to ungenerated
      #SET(%GenerateProgram,%True)                          #!  Set program flag to be generated
      #CREATE(%SourceFile)                                  #!  Create module source file
      #GENERATE(%Module)                                    #!  Generate the module source code
      #FOR(%ModuleProcedure)                                #!  For all module procedures
        #FIX(%Procedure,%ModuleProcedure)                   #!   Fix the procedure to the module procedure
        #MESSAGE('Generating Procedure: ' & %Procedure,2)
        #GENERATE(%Procedure)                               #!   Generate the procedure source code
      #ENDFOR
      #CLOSE(%SourceFile)                                   #!  Close the module source file
      #REPLACE(%Module,%SourceFile)                         #!  Replace the existing module file with the source file
      #REMOVE(%SourceFile)                                  #!  Delete the module source file
      #SET(%ModuleGenerated,%True)                          #!  Set module flag to generated
    #ENDIF
  #ENDFOR
#!------------------------------------------------------------------------------
  #FIX(%Module,%Program)                                    #! Fix the module to program module
  #MESSAGE('Generating Program:   ' & %Module,1)
  #SET(%GenerateModule,%True)                               #! Set program module to be generated
  #IF(%ModuleChanged)                                       #! If program module has been changed
  #ELSIF(%GlobalRegenerate)                                 #! If generating everything
  #ELSIF(NOT %ModuleGenerated)                              #! If program module flagged as ungenerated
  #ELSIF(NOT FILEEXISTS(%Module))                           #! If program module does not exist
  #ELSIF(%GenerateProgram)                                  #! If program flagged to be generated
  #ELSIF(%ModuleExternal)                                   #!  If module is external source
    #SET(%GenerateModule,%False)                            #!   Cancel program module generation
  #ELSE                                                     #!  Else no other checks
    #SET(%GenerateModule,%False)                            #!   Cancel program module generation
  #ENDIF
#!------------------------------------------------------------------------------
  #IF(%GenerateModule)                                      #! If program module to be generated
    #SET(%ModuleGenerated,%False)                           #!  Set program module flag to ungenerated
    #EMBED(%BeforeGenerateProgram,'Before Generating Program'),HIDE
    #CREATE(%SourceFile)                                    #!  Create module source file
    #MESSAGE('Generating Program Code',2)
    #GENERATE(%Program)                                     #!  Generate program source code
    #FOR(%ModuleProcedure)                                  #!  For all program module procedures
      #FIX(%Procedure,%ModuleProcedure)                     #!   Fix the procedure to the program module procedure
      #MESSAGE('Generating Procedure: ' & %Procedure,2)
      #GENERATE(%Procedure)                                 #!   Generate the program procedure source code
    #ENDFOR
    #CLOSE(%SourceFile)                                     #!  Close the module source file
    #REPLACE(%Program,%SourceFile)                          #!  Replace the existing program file with the source file
    #REMOVE(%SourceFile)                                    #!  Delete the module source file
  #ENDIF
#!------------------------------------------------------------------------------
#EMBED(%AfterApplicationGeneration,'Application - After Generation'),HIDE
#!==========================================================================
#! Template Chain Includes
#!==========================================================================
#INCLUDE('ror.tpi')                    
#!==========================================================================
#!==========================================================================
