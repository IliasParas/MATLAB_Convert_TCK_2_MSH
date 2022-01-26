clear
clc
tic
%% Files
% File to write
tracts_msh = fopen('tracts3.msh','w');   % The format explaind here: http://www.manpagez.com/info/gmsh/gmsh-2.2.6/gmsh_63.php
% Files to read
mrtrix = read_mrtrix_tracks('5M_COMMIT2filtered.tck');
load('assignments.csv')
load('connectome_symmetric.mat')

%% Write the first lines
fprintf(tracts_msh,'$MeshFormat\n');
fprintf(tracts_msh,'2.2 0 8\n');
fprintf(tracts_msh,'$EndMeshFormat\n');
fprintf(tracts_msh,'$Nodes\n');
nodes = 0;

for k=1:length(assignments)
    for t = 1:length(mrtrix.data{1,k})
        nodes = nodes + 1;
    end
end
fprintf(tracts_msh,'%d\n',nodes); %segments = nodes - length(ilias.data)
toc
tic
%% Nodes
node = 1;
% th1 = pi;
% transform = [cos(th1), -sin(th1), 0;
%              sin(th1),  cos(th1), 0;
%                 0,         0,     1];
for k=1:length(assignments)
    for t = 1:length(mrtrix.data{1,k})
        fprintf(tracts_msh,'%i %.2f %.2f %.2f\n', node, mrtrix.data{1,k}(t,:));%*transform);
        node = node+1;
    end
end
toc
tic
%% Write lines
fprintf(tracts_msh,'$EndNodes\n');
fprintf(tracts_msh,'$Elements\n');
fprintf(tracts_msh,'%i\n',nodes - length(mrtrix.data)); %segments = nodes - length(ilias.data)

%% Segments
node    = 1;
segment = 1;
for k=1:length(assignments)
    for t = 1:length(mrtrix.data{1,k})
        if t == length(mrtrix.data{1,k})
            node = node+1;
        else
            
            % insert color
            col = abs(mrtrix.data{1,k}(t,:)-mrtrix.data{1,k}(t+1,:));
            if col(1,1)>col(1,2) && col(1,1)>col(1,3)
                color = 1;
            elseif col(1,2)>col(1,1) && col(1,2)>col(1,3)
                color = 2;
            else
                color = 3;
            end

            fprintf(tracts_msh,'%i 1 2 %i 0 %i %i\n', segment, color, node, node+1);
            node    = node+1;
            segment = segment+1;
        end
    end
end
            
%% Write the last line
fprintf(tracts_msh,'$EndElements');

fclose('all');
toc