/*********************************************
 * OPL 22.1.1.0 Model
 * Author: Anass
 * Creation Date: 4 mai 2024 at 15:09:50
 *********************************************/

main {
    var source = new IloOplModelSource("NEW_TER_PROJECT.mod");
    var def = new IloOplModelDefinition(source);
    var opl = new IloOplModel(def, cplex);

    var data = new IloOplDataSource("Data.dat");
    opl.addDataSource(data);

    opl.generate();
    if (cplex.solve()) {
        var ofile = new IloOplOutputFile("C:/Users/Anass/Desktop/Ter_projet/Ter_project/tertxt");
        ofile.writeln(opl.printSolution());
        ofile.writeln("Binary setup variable:",opl.Y.solutionValue); 
        ofile.writeln("Quantite de desassemblage",opl.X.solutionValue);
        ofile.writeln("Surcharge de desassemblage",opl.O.solutionValue); 
        ofile.writeln("Niveau d'inventaire",opl.I.solutionValue); 
        ofile.writeln("Quantite de vente perdue",opl.L.solutionValue); 
       ofile.close();
       writeln("solution optimale");
       writeln();
       writeln("Binary setup variable:",opl.Y.solutionValue);
       writeln("Quantite de desassemblage",opl.X.solutionValue);
       writeln("Surcharge de desassemblage:",opl.O.solutionValue);
       writeln("Niveau d'inventaire:",opl.I.solutionValue);
       writeln("Quantite de vente perdue:",opl.L.solutionValue);
       writeln("Total cost :",cplex.getObjValue());
            
    }       else
                { 
                writeln("aucune solution");
                }
  
}



//indices
int NB_periods = ...;
range periods = 1..NB_periods;
int NB_leaf_items = ...;
range leaf_items = 1..NB_leaf_items;
int NB_root_items = ...;
range root_items = 1..NB_root_items;

//paramètres d'entrée
int S[root_items] = ...;
int H[leaf_items] = ...;
int l[leaf_items] = ...;
int A[root_items][leaf_items] = ...;
int D[leaf_items][periods] = ...;
int G[root_items] = ...;
int C = ...;    
int u=...;
int M=...;
//variables de décision
dvar float Y[root_items][periods] in 0..1; //LP and FIX 
//dvar boolean Y[root_items][periods];   // pour le modele original
dvar int+ X[root_items][periods];   
dvar float+ O[periods];
dvar int+ I[leaf_items][periods];  
dvar int+ L[leaf_items][periods];      



execute
{
  cplex.tilim=300;
}

//fonction objectif : minimiser le coût
minimize sum(t in periods)(sum(r in root_items)(S[r]*Y[r][t])+ sum(i in leaf_items)(H[i]*I[i][t] + l[i]*L[i][t]) + u*O[t]);

//contraintes
subject to {
    // Initialisation
 forall(i in leaf_items)
   //      I[i][0]==0;  // l'indice 0 ne finctionne pas dans le cplex'
         I[i][1]==40 + L[i][1] + sum(r in root_items)(A[r][i]*X[r][1]) ;//- D[i][1];  // 40, I[i][0] est inventaire initiale
        
    // Initial_inventory
    forall(i in leaf_items,t in periods:t>1)
    // I[i][t] == I[i][t-1] + R[i][t] + L[i][t] - Z[i][t] + A[r][i]*X[r][t] - D[i][t];   // cette contrainte n'est pas correct dans le papier de Hruga'
       I[i][t] == I[i][t-1]+ L[i][t] + sum(r in root_items)(A[r][i]*X[r][t])- D[i][t];   // la correction
    // Disassambly_quantity
    forall(r in root_items,t in periods)
            X[r][t] <= M*Y[r][t]; // Correction de la contrainte

    // Sumof_Operation_root
    forall(t in periods)
        sum(r in root_items)(G[r]*X[r][t]) <= C;  

    // Lost_sales_quantity
   forall(i in leaf_items,t in periods)
        L[i][t] <= D[i][t];

    // Non-negativity constraints
    forall(r in root_items, t in periods)
        X[r][t] >= 0;

    forall(i in leaf_items, t in periods)
        I[i][t] >= 0;

    forall(i in leaf_items, t in periods)
        L[i][t] >= 0;

}
