
%Réalisé par Mohamed Raiss El Fenni
%Numéro d’étudiants: 300296996



% dataset(DirectoryName)
% this is where the image dataset is located
%dataset('C:\\Users\\Documents\\imageDataset2_15_20\\').
dataset('C:\\Users\\Ordinateur\\Documents\\computer_science\\paradigmes\\devoir\\imageDataset2\\').

% directory_textfiles(DirectoryName, ListOfTextfiles)
% produces the list of text files in a directory
directory_textfiles(D,Textfiles):- directory_files(D,Files), include(isTextFile, Files, Textfiles).
isTextFile(Filename):-string_concat(_,'.txt',Filename).
% read_hist_file(Filename,ListOfNumbers)
% reads a histogram file and produces a list of numbers (bin values)
read_hist_file(Filename,Numbers):- open(Filename,read,Stream),read_line_to_string(Stream,_),
                                   read_line_to_string(Stream,String), close(Stream),
								   atomic_list_concat(List, ' ', String),atoms_numbers(List,Numbers).
								   
% similarity_search(QueryFile,SimilarImageList)
% returns the list of images similar to the query image
% similar images are specified as (ImageName, SimilarityScore)
% predicat dataset/1 provides the location of the image set
similarity_search(QueryFile,SimilarList) :- dataset(D), directory_textfiles(D,TxtFiles),
                                            similarity_search(QueryFile,D,TxtFiles,SimilarList).
											
% similarity_search(QueryFile, DatasetDirectory, HistoFileList, SimilarImageList)
similarity_search(QueryFile,DatasetDirectory, DatasetFiles,Best):- read_hist_file(QueryFile,QueryHisto), 
                                            compare_histograms(QueryHisto, DatasetDirectory, DatasetFiles, Scores), 
                                            sort(2,@>,Scores,Sorted),take(Sorted,5,Best).

% compare_histograms(QueryHisto,DatasetDirectory,DatasetFiles,Scores)
% compares a query histogram with a list of histogram files 
compare_histograms(_, _, [], []).
compare_histograms(QueryHisto, DatasetDirectory, [File|Rest], [(File, Score)|Scores]) :-
    atomic_list_concat([DatasetDirectory, File], '/', FullPath), % Construire le chemin complet du fichier d'histogramme
    read_hist_file(FullPath, DatasetHisto), % Lire l'histogramme du fichier
    histogram_intersection(QueryHisto, DatasetHisto, Score), % Calculer la similarité
    compare_histograms(QueryHisto, DatasetDirectory, Rest, Scores).


% histogram_intersection(Histogram1, Histogram2, Score)
% compute the intersection similarity score between two histograms
% Score is between 0.0 and 1.0 (1.0 for identical histograms)
histogram_intersection(H1, H2, S) :-
  normalize_histogram(H1, NormH1),
  normalize_histogram(H2, NormH2),
  sum_of_min(NormH1, NormH2, SumMin),
  S is SumMin.

%sum_of_min([H1|T1], [H2|T2], SumMin)
%This predicate recursively calculates the sum of the minimum values for each bin of the histograms H1 and H2.
sum_of_min([], [], 0).
sum_of_min([H1|T1], [H2|T2], SumMin) :-
  Min is min(H1, H2),
  sum_of_min(T1, T2, RestSumMin),
  SumMin is Min + RestSumMin.

% normalize_histogram(Histogram, NormalizedHistogram)
% Normalizes the values of a histogram to sum up to 1
normalize_histogram(Histogram, NormalizedHistogram) :-
    sum_list(Histogram, Sum),
    normalize_histogram_helper(Histogram, Sum, NormalizedHistogram).

% normalize_histogram_helper(Histogram, TotalSum, NormalizedHistogram)
% Helper predicate to normalize the histogram
normalize_histogram_helper([], _, []).
normalize_histogram_helper([H|T], TotalSum, [NormalizedValue|RestNormalized]) :-
    NormalizedValue is H / TotalSum,
    normalize_histogram_helper(T, TotalSum, RestNormalized).



% take(List,K,KList)
% extracts the K first items in a list
take(Src,N,L) :- findall(E, (nth1(I,Src,E), I =< N), L).
% atoms_numbers(ListOfAtoms,ListOfNumbers)
% converts a list of atoms into a list of numbers
atoms_numbers([],[]).
atoms_numbers([X|L],[Y|T]):- atom_number(X,Y), atoms_numbers(L,T).
atoms_numbers([X|L],T):- \+atom_number(X,_), atoms_numbers(L,T).
