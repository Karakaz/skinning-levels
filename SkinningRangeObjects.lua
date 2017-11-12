
SkinningLevels.orange = {}
SkinningLevels.yellow = {}
SkinningLevels.green = {}

function SkinningLevels.orange:calcRange(rank)
  
  if rank < 100 then
    self.max = (rank / 10) + 10
  else
    self.max = rank / 5
    if self.max > 73 then
      self.max = '??'
    end
  end

  if rank < 25 then
    self.min = 1
  elseif rank >= 25 and rank < 125 then
    self.min = ((rank - 5) / 10) + 9
  else
    self.min = (rank / 5) - 4
  end
  
  if type(self.max) == 'number' then
    self.max = floor(self.max)
  end
  self.min = floor(self.min)
end

function SkinningLevels.yellow:calcRange(rank)
  
  if rank >= 25 then
  
    if rank < 125 then
      self.max = ((rank - 5) / 10) + 8
    elseif rank >= 125 then
      self.max = (rank / 5) - 5
    end
      
    if rank < 50 then
      self.min = 1
    elseif rank >= 50 and rank < 150 then
      self.min = (rank / 10) + 6
    elseif rank >= 150 then
      self.min = (rank / 5) - 9
    end
    
    self.max = floor(self.max)
    self.min = floor(self.min)
  else
    self.max = nil
    self.min = nil
  end
  
end

function SkinningLevels.green:calcRange(rank)
  
  if rank >= 50 then
  
    if rank < 150 then
      self.max = (rank / 10) + 5
    elseif rank >= 150 then
      self.max = (rank / 5) - 10
    end
    
    if rank < 100 then
      self.min = 1
    elseif rank >= 100 and rank < 200 then
      self.min = (rank / 10) + 1
    elseif rank >= 200 then
      self.min = (rank / 5) - 19
    end
   
    self.max = floor(self.max)
    self.min = floor(self.min)
  else
    self.max = nil
    self.min = nil
  end
end
