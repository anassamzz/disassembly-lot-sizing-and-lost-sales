/*********************************************
 * OPL 22.1.1.0 Model
 * Author: Anass
 * Creation Date: 9 mai 2024 at 23:20:01
 *********************************************/

main {
  //creation du modele
var source = new IloOplModelSource("NEW_TER_PROJECT.mod");
    var def = new IloOplModelDefinition(source);
    var opl = new IloOplModel(def, cplex);
//Ajouter les donnees
    var data = new IloOplDataSource("Data.dat");
    opl.addDataSource(data);
    
    //Relaxer les contraintes
    opl.convertAllIntVars();
    //Generer le modele
    opl.generate();
    
    if(cplex.solve())
    {
      //create second model instance with its own CPLEX engine for fixing the binary variable values
      var cplex2=new IloCplex();
      var opl2 =new IloOplModel(def,cplex2);
      opl2.addDataSource(data);
      opl2.generate();
      
          //Fix the binary variable values
    
  
  for (var i=1;i<=opl.dataElements.NB_root_items;i++)
   { for (var t=1;t<=opl.dataElements.NB_periods;t++)
      {
				if (opl.Y[i][t].solutionValue==0) 
					{
						opl2.Y[i][t].LB = 0;
						opl2.Y[i][t].UB = 0;
					}
				else if (opl.Y[i][t].solutionValue > 0.0000001) 
					{
				  		opl2.Y[i][t].LB = 1;
						opl2.Y[i][t].UB = 1;
					}	
				}
 }   

     if(cplex2.solve())
     {
       writeln("LP-and-Fix-Heuristic");
       writeln();
       writeln("Binary setup variable:",opl2.Y.solutionValue);
       writeln("Quantite de desassemblage",opl2.X.solutionValue);
       writeln("Surcharge de desassemblage:",opl2.O.solutionValue);
       writeln("Niveau d'inventaire:",opl2.I.solutionValue);
       writeln("Quantite de vente perdue:",opl2.L.solutionValue);
       writeln("Total cost :",cplex2.getObjValue());
       
       }
       
          
     }
     else{
       writeln("No solution found");
       }
  }             
      